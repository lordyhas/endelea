// Endelea — local database schema (Drift / SQLite)
//
// Design principles:
// - The local database is the source of truth; cloud sync (Drive/OneDrive) only mirrors it.
// - Every table uses a UUID text primary key so records created offline on
//   different devices never collide when merged.
// - Every table carries createdAt / updatedAt / deleted (soft delete) so the
//   sync layer can apply "last write wins" and propagate deletions.
// - Weights are always stored in kilograms; display units are a user setting.
// - Only repositories write rows: they set updatedAt and lastModifiedBy.

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

const _uuid = Uuid();

/// Columns shared by every synced table.
mixin SyncColumns on Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  /// `deviceId` of the device that wrote the row last (sync tie-break).
  TextColumn get lastModifiedBy => text().withDefault(const Constant(''))();
}

// ---------------------------------------------------------------------------
// Catalog
// ---------------------------------------------------------------------------

/// An exercise definition (e.g. "Bench press"). Built-in or user-created.
class Exercises extends Table with SyncColumns {
  TextColumn get name => text().withLength(min: 1, max: 120)();

  /// Stable key of a built-in exercise (e.g. `bench_press`). The displayed
  /// name then comes from the ARB key `exercise_<builtInKey>`.
  TextColumn get builtInKey => text().nullable().unique()();
  TextColumn get muscleGroup => text().nullable()(); // e.g. "chest", "legs"
  TextColumn get equipment => text().nullable()(); // e.g. "barbell", "machine"
  /// How the exercise is measured: weight_reps, reps_only, duration, distance.
  TextColumn get trackingType =>
      text().withDefault(const Constant('weight_reps'))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Planning: programs → program days → planned exercises
// ---------------------------------------------------------------------------

/// A training program (e.g. "Push / Pull / Legs").
class Programs extends Table with SyncColumns {
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A day/workout inside a program (e.g. "Day A — Push").
class ProgramDays extends Table with SyncColumns {
  TextColumn get programId => text().references(Programs, #id)();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A planned exercise within a program day, with its targets.
/// This is what the guided "auto-play" session walks through.
class ProgramExercises extends Table with SyncColumns {
  TextColumn get programDayId => text().references(ProgramDays, #id)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get orderIndex => integer()();
  IntColumn get targetSets => integer().withDefault(const Constant(3))();
  IntColumn get targetRepsMin => integer().nullable()();
  IntColumn get targetRepsMax => integer().nullable()();
  RealColumn get targetWeightKg => real().nullable()();
  IntColumn get targetDurationSeconds => integer().nullable()();
  IntColumn get restSeconds => integer().withDefault(const Constant(90))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Logging: sessions → session exercises → sets
// ---------------------------------------------------------------------------

/// A workout actually performed. Can follow a program day or be ad hoc.
class WorkoutSessions extends Table with SyncColumns {
  TextColumn get programDayId =>
      text().nullable().references(ProgramDays, #id)();
  TextColumn get name => text().nullable()(); // copied from the day, editable
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()(); // null = in progress
  TextColumn get notes => text().nullable()();

  /// Optional, for bodyweight exercises.
  RealColumn get bodyWeightKg => real().nullable()();

  /// End of the current rest, if resting. Stored as a timestamp so the rest
  /// survives the app going to the background or being killed.
  DateTimeColumn get restEndsAt => dateTime().nullable()();

  /// Set while the session is paused.
  DateTimeColumn get pausedAt => dateTime().nullable()();

  /// Total paused time of past pauses, excluded from the session duration.
  IntColumn get pausedSeconds => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// An exercise performed during a session.
class SessionExercises extends Table with SyncColumns {
  TextColumn get sessionId => text().references(WorkoutSessions, #id)();
  TextColumn get exerciseId => text().references(Exercises, #id)();

  /// Link back to the plan, to compare performed vs. target.
  TextColumn get programExerciseId =>
      text().nullable().references(ProgramExercises, #id)();
  IntColumn get orderIndex => integer()();
  TextColumn get notes => text().nullable()();

  /// Targets copied from the plan when the session starts, so editing the
  /// program later does not change the history.
  IntColumn get targetRepsMin => integer().nullable()();
  IntColumn get targetRepsMax => integer().nullable()();
  IntColumn get restSeconds => integer().withDefault(const Constant(90))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A single set: the core data behind all progress reports.
///
/// Sets are created up front, pre-filled with the target; `completedAt`
/// marks a set as done.
class SetEntries extends Table with SyncColumns {
  TextColumn get sessionExerciseId =>
      text().references(SessionExercises, #id)();
  IntColumn get setIndex => integer()();
  IntColumn get reps => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  RealColumn get distanceMeters => real().nullable()();
  RealColumn get rpe => real().nullable()(); // rate of perceived exertion, 1–10
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Body tracking (optional, for progress reports)
// ---------------------------------------------------------------------------

class BodyMeasurements extends Table with SyncColumns {
  DateTimeColumn get measuredAt => dateTime()();
  RealColumn get bodyWeightKg => real().nullable()();
  RealColumn get bodyFatPercent => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Local-only state (never synced)
// ---------------------------------------------------------------------------

/// Key/value store for sync bookkeeping: `deviceId`, `lastPushAt`,
/// `lastPullCursor` (JSON), `provider`, `accountEmail`.
@DataClassName('SyncMetaEntry')
class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

/// Synced tables, in the order the sync applies them (parents first).
const syncedTableNames = [
  'exercises',
  'programs',
  'program_days',
  'program_exercises',
  'workout_sessions',
  'session_exercises',
  'set_entries',
  'body_measurements',
];

@DriftDatabase(
  tables: [
    Exercises,
    Programs,
    ProgramDays,
    ProgramExercises,
    WorkoutSessions,
    SessionExercises,
    SetEntries,
    BodyMeasurements,
    SyncMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Indexes for the most common lookups and progress queries.
      await customStatement(
        'CREATE INDEX idx_set_entries_session_exercise '
        'ON set_entries (session_exercise_id)',
      );
      await customStatement(
        'CREATE INDEX idx_session_exercises_session '
        'ON session_exercises (session_id)',
      );
      await customStatement(
        'CREATE INDEX idx_session_exercises_exercise '
        'ON session_exercises (exercise_id)',
      );
      await customStatement(
        'CREATE INDEX idx_workout_sessions_started_at '
        'ON workout_sessions (started_at)',
      );
      await customStatement(
        'CREATE INDEX idx_program_days_program ON program_days (program_id)',
      );
      await customStatement(
        'CREATE INDEX idx_program_exercises_day '
        'ON program_exercises (program_day_id)',
      );
      // Sync push selects rows by updated_at.
      for (final table in syncedTableNames) {
        await customStatement(
          'CREATE INDEX idx_${table}_updated_at ON $table (updated_at)',
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
