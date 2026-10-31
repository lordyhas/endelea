import 'package:drift/drift.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/watch.dart';
import 'package:endelea/data/repositories/write_stamp.dart';
import 'package:endelea/domain/models/ordering.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:uuid/uuid.dart';

/// The next day to train: the one after the last day done (sequential
/// rotation, PLAN.md §15.3).
class NextProgramDay {
  const NextProgramDay({required this.program, required this.day});

  final Program program;
  final ProgramDaySummary day;
}

class ProgramRepository {
  ProgramRepository(this._db, this._stamp);

  final AppDatabase _db;
  final WriteStamp _stamp;
  static const _uuid = Uuid();

  // -------------------------------------------------------------------------
  // Reads
  // -------------------------------------------------------------------------

  Stream<List<ProgramSummary>> watchSummaries() => _db.watchComposite([
    _db.programs,
    _db.programDays,
    _db.workoutSessions,
  ], getSummaries);

  Future<List<ProgramSummary>> getSummaries() async {
    final rows = await _db
        .customSelect(
          '''
      SELECT p.*,
        (SELECT COUNT(*) FROM program_days d
          WHERE d.program_id = p.id AND d.deleted = 0) AS day_count,
        (SELECT MAX(ws.started_at) FROM workout_sessions ws
          JOIN program_days d2 ON d2.id = ws.program_day_id
          WHERE d2.program_id = p.id AND ws.deleted = 0
            AND ws.ended_at IS NOT NULL) AS last_session_at
      FROM programs p
      WHERE p.deleted = 0
      ORDER BY p.created_at
      ''',
          readsFrom: {_db.programs, _db.programDays, _db.workoutSessions},
        )
        .get();
    return [
      for (final row in rows)
        ProgramSummary(
          program: _db.programs.map(row.data),
          dayCount: row.read<int>('day_count'),
          lastSessionAt: row.readNullable<DateTime>('last_session_at'),
        ),
    ];
  }

  Future<Program?> getProgram(String id) {
    return (_db.select(_db.programs)
          ..where((t) => t.id.equals(id) & t.deleted.equals(false)))
        .getSingleOrNull();
  }

  Stream<ProgramDetails?> watchDetails(String programId) => _db.watchComposite([
    _db.programs,
    _db.programDays,
    _db.programExercises,
  ], () => getDetails(programId));

  Future<ProgramDetails?> getDetails(String programId) async {
    final program = await getProgram(programId);
    if (program == null) return null;
    return ProgramDetails(
      program: program,
      days: await _daySummaries(programId),
    );
  }

  Future<List<ProgramDaySummary>> _daySummaries(String programId) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT d.*,
        (SELECT COUNT(*) FROM program_exercises pe
          WHERE pe.program_day_id = d.id AND pe.deleted = 0) AS exercise_count
      FROM program_days d
      WHERE d.program_id = ? AND d.deleted = 0
      ORDER BY d.order_index
      ''',
          variables: [Variable.withString(programId)],
          readsFrom: {_db.programDays, _db.programExercises},
        )
        .get();
    return [
      for (final row in rows)
        ProgramDaySummary(
          day: _db.programDays.map(row.data),
          exerciseCount: row.read<int>('exercise_count'),
        ),
    ];
  }

  Stream<ProgramDayDetails?> watchDay(String dayId) => _db.watchComposite([
    _db.programs,
    _db.programDays,
    _db.programExercises,
    _db.exercises,
  ], () => getDay(dayId));

  Future<ProgramDayDetails?> getDay(String dayId) async {
    final day =
        await (_db.select(_db.programDays)
              ..where((t) => t.id.equals(dayId) & t.deleted.equals(false)))
            .getSingleOrNull();
    if (day == null) return null;
    final program = await getProgram(day.programId);
    if (program == null) return null;
    return ProgramDayDetails(
      program: program,
      day: day,
      exercises: await getPlannedExercises(dayId),
    );
  }

  Future<List<PlannedExercise>> getPlannedExercises(String dayId) async {
    final query =
        _db.select(_db.programExercises).join([
            innerJoin(
              _db.exercises,
              _db.exercises.id.equalsExp(_db.programExercises.exerciseId),
            ),
          ])
          ..where(
            _db.programExercises.programDayId.equals(dayId) &
                _db.programExercises.deleted.equals(false) &
                _db.exercises.deleted.equals(false),
          )
          ..orderBy([OrderingTerm.asc(_db.programExercises.orderIndex)]);
    final rows = await query.get();
    return [
      for (final row in rows)
        PlannedExercise(
          plan: row.readTable(_db.programExercises),
          exercise: row.readTable(_db.exercises),
        ),
    ];
  }

  Stream<NextProgramDay?> watchNextDay() => _db.watchComposite([
    _db.programs,
    _db.programDays,
    _db.programExercises,
    _db.workoutSessions,
  ], getNextDay);

  /// The day after the last finished one in the active program.
  Future<NextProgramDay?> getNextDay() async {
    final program =
        await (_db.select(_db.programs)
              ..where((t) => t.isActive.equals(true) & t.deleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
    if (program == null) return null;
    final days = await _daySummaries(program.id);
    if (days.isEmpty) return null;

    final dayIds = days.map((d) => d.day.id).toList();
    final last =
        await (_db.select(_db.workoutSessions)
              ..where(
                (t) =>
                    t.programDayId.isIn(dayIds) &
                    t.deleted.equals(false) &
                    t.endedAt.isNotNull(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    final lastIndex = last == null ? -1 : dayIds.indexOf(last.programDayId!);
    return NextProgramDay(
      program: program,
      day: days[(lastIndex + 1) % days.length],
    );
  }

  // -------------------------------------------------------------------------
  // Programs
  // -------------------------------------------------------------------------

  /// Creates a program. The first program becomes the active one.
  Future<String> createProgram(String name, {String? description}) {
    return _db.transaction(() async {
      final hasActive =
          await (_db.select(_db.programs)..where(
                (t) => t.isActive.equals(true) & t.deleted.equals(false),
              ))
              .get()
              .then((r) => r.isNotEmpty);
      final now = _stamp.now();
      final row = await _db
          .into(_db.programs)
          .insertReturning(
            ProgramsCompanion.insert(
              name: name.trim(),
              description: Value(_blankToNull(description)),
              isActive: Value(!hasActive),
              createdAt: Value(now),
              updatedAt: Value(now),
              lastModifiedBy: Value(_stamp.deviceId),
            ),
          );
      return row.id;
    });
  }

  Future<void> updateProgram(
    String id, {
    required String name,
    String? description,
  }) {
    return (_db.update(_db.programs)..where((t) => t.id.equals(id))).write(
      ProgramsCompanion(
        name: Value(name.trim()),
        description: Value(_blankToNull(description)),
        updatedAt: Value(_stamp.now()),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }

  /// Makes [id] the only active program.
  Future<void> activate(String id) {
    return _db.transaction(() async {
      final now = _stamp.now();
      await (_db.update(
        _db.programs,
      )..where((t) => t.isActive.equals(true) & t.id.equals(id).not())).write(
        ProgramsCompanion(
          isActive: const Value(false),
          updatedAt: Value(now),
          lastModifiedBy: Value(_stamp.deviceId),
        ),
      );
      await (_db.update(_db.programs)..where((t) => t.id.equals(id))).write(
        ProgramsCompanion(
          isActive: const Value(true),
          updatedAt: Value(now),
          lastModifiedBy: Value(_stamp.deviceId),
        ),
      );
    });
  }

  /// Copies a program with its days and planned exercises.
  Future<String> duplicate(String id, {required String name}) {
    return _db.transaction(() async {
      final source = await getProgram(id);
      if (source == null) throw StateError('Program $id not found');
      final now = _stamp.now();
      final newId = _uuid.v4();
      await _db
          .into(_db.programs)
          .insert(
            ProgramsCompanion.insert(
              id: Value(newId),
              name: name.trim(),
              description: Value(source.description),
              createdAt: Value(now),
              updatedAt: Value(now),
              lastModifiedBy: Value(_stamp.deviceId),
            ),
          );
      final days = await (_db.select(
        _db.programDays,
      )..where((t) => t.programId.equals(id) & t.deleted.equals(false))).get();
      for (final day in days) {
        final dayId = _uuid.v4();
        await _db
            .into(_db.programDays)
            .insert(
              day
                  .toCompanion(false)
                  .copyWith(
                    id: Value(dayId),
                    programId: Value(newId),
                    createdAt: Value(now),
                    updatedAt: Value(now),
                    lastModifiedBy: Value(_stamp.deviceId),
                  ),
            );
        final planned =
            await (_db.select(_db.programExercises)..where(
                  (t) =>
                      t.programDayId.equals(day.id) & t.deleted.equals(false),
                ))
                .get();
        for (final plan in planned) {
          await _db
              .into(_db.programExercises)
              .insert(
                plan
                    .toCompanion(false)
                    .copyWith(
                      id: Value(_uuid.v4()),
                      programDayId: Value(dayId),
                      createdAt: Value(now),
                      updatedAt: Value(now),
                      lastModifiedBy: Value(_stamp.deviceId),
                    ),
              );
        }
      }
      return newId;
    });
  }

  /// Soft-deletes a program with its days and planned exercises.
  Future<void> deleteProgram(String id) {
    return _db.transaction(() async {
      final days = await (_db.select(
        _db.programDays,
      )..where((t) => t.programId.equals(id) & t.deleted.equals(false))).get();
      for (final day in days) {
        await _deleteDay(day.id);
      }
      await (_db.update(_db.programs)..where((t) => t.id.equals(id))).write(
        ProgramsCompanion(
          deleted: const Value(true),
          isActive: const Value(false),
          updatedAt: Value(_stamp.now()),
          lastModifiedBy: Value(_stamp.deviceId),
        ),
      );
    });
  }

  // -------------------------------------------------------------------------
  // Days
  // -------------------------------------------------------------------------

  Future<String> addDay(String programId, String name) {
    return _db.transaction(() async {
      final days =
          await (_db.select(_db.programDays)..where(
                (t) => t.programId.equals(programId) & t.deleted.equals(false),
              ))
              .get();
      final last = days.isEmpty
          ? null
          : days.map((d) => d.orderIndex).reduce((a, b) => a > b ? a : b);
      final now = _stamp.now();
      final row = await _db
          .into(_db.programDays)
          .insertReturning(
            ProgramDaysCompanion.insert(
              programId: programId,
              name: name.trim(),
              orderIndex: nextOrderIndex(last),
              createdAt: Value(now),
              updatedAt: Value(now),
              lastModifiedBy: Value(_stamp.deviceId),
            ),
          );
      return row.id;
    });
  }

  Future<void> renameDay(String dayId, String name) {
    return (_db.update(
      _db.programDays,
    )..where((t) => t.id.equals(dayId))).write(
      ProgramDaysCompanion(
        name: Value(name.trim()),
        updatedAt: Value(_stamp.now()),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }

  Future<void> deleteDay(String dayId) =>
      _db.transaction(() => _deleteDay(dayId));

  Future<void> _deleteDay(String dayId) async {
    final now = _stamp.now();
    await (_db.update(
          _db.programExercises,
        )..where((t) => t.programDayId.equals(dayId) & t.deleted.equals(false)))
        .write(
          ProgramExercisesCompanion(
            deleted: const Value(true),
            updatedAt: Value(now),
            lastModifiedBy: Value(_stamp.deviceId),
          ),
        );
    await (_db.update(_db.programDays)..where((t) => t.id.equals(dayId))).write(
      ProgramDaysCompanion(
        deleted: const Value(true),
        updatedAt: Value(now),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }

  Future<void> moveDay(String programId, int oldIndex, int newIndex) {
    return _db.transaction(() async {
      final days =
          await (_db.select(_db.programDays)
                ..where(
                  (t) =>
                      t.programId.equals(programId) & t.deleted.equals(false),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
              .get();
      final changes = moveOrderIndex(
        days.map((d) => d.orderIndex).toList(),
        oldIndex,
        newIndex,
      );
      final now = _stamp.now();
      for (final MapEntry(key: position, value: index) in changes.entries) {
        await (_db.update(
          _db.programDays,
        )..where((t) => t.id.equals(days[position].id))).write(
          ProgramDaysCompanion(
            orderIndex: Value(index),
            updatedAt: Value(now),
            lastModifiedBy: Value(_stamp.deviceId),
          ),
        );
      }
    });
  }

  // -------------------------------------------------------------------------
  // Planned exercises
  // -------------------------------------------------------------------------

  Future<void> addExercises(
    String dayId,
    List<String> exerciseIds, {
    required ExerciseTargets defaults,
  }) {
    return _db.transaction(() async {
      final existing = await getPlannedExercises(dayId);
      var last = existing.isEmpty ? null : existing.last.plan.orderIndex;
      final now = _stamp.now();
      for (final exerciseId in exerciseIds) {
        final index = nextOrderIndex(last);
        last = index;
        await _db
            .into(_db.programExercises)
            .insert(
              ProgramExercisesCompanion.insert(
                programDayId: dayId,
                exerciseId: exerciseId,
                orderIndex: index,
                targetSets: Value(defaults.sets),
                targetRepsMin: Value(defaults.repsMin),
                targetRepsMax: Value(defaults.repsMax),
                targetWeightKg: Value(defaults.weightKg),
                targetDurationSeconds: Value(defaults.durationSeconds),
                restSeconds: Value(defaults.restSeconds),
                createdAt: Value(now),
                updatedAt: Value(now),
                lastModifiedBy: Value(_stamp.deviceId),
              ),
            );
      }
    });
  }

  Future<void> updateTargets(String plannedId, ExerciseTargets targets) {
    return (_db.update(
      _db.programExercises,
    )..where((t) => t.id.equals(plannedId))).write(
      ProgramExercisesCompanion(
        targetSets: Value(targets.sets),
        targetRepsMin: Value(targets.repsMin),
        targetRepsMax: Value(targets.repsMax),
        targetWeightKg: Value(targets.weightKg),
        targetDurationSeconds: Value(targets.durationSeconds),
        restSeconds: Value(targets.restSeconds),
        notes: Value(_blankToNull(targets.notes)),
        updatedAt: Value(_stamp.now()),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }

  Future<void> removePlannedExercise(String plannedId) {
    return (_db.update(
      _db.programExercises,
    )..where((t) => t.id.equals(plannedId))).write(
      ProgramExercisesCompanion(
        deleted: const Value(true),
        updatedAt: Value(_stamp.now()),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }

  Future<void> movePlannedExercise(String dayId, int oldIndex, int newIndex) {
    return _db.transaction(() async {
      final planned = await getPlannedExercises(dayId);
      final changes = moveOrderIndex(
        planned.map((p) => p.plan.orderIndex).toList(),
        oldIndex,
        newIndex,
      );
      final now = _stamp.now();
      for (final MapEntry(key: position, value: index) in changes.entries) {
        await (_db.update(
          _db.programExercises,
        )..where((t) => t.id.equals(planned[position].plan.id))).write(
          ProgramExercisesCompanion(
            orderIndex: Value(index),
            updatedAt: Value(now),
            lastModifiedBy: Value(_stamp.deviceId),
          ),
        );
      }
    });
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
