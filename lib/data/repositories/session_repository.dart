import 'package:drift/drift.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/watch.dart';
import 'package:endelea/data/repositories/write_stamp.dart';
import 'package:endelea/domain/models/ordering.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:uuid/uuid.dart';

/// Thrown when starting a session while another one is in progress.
class ActiveSessionExistsException implements Exception {
  const ActiveSessionExistsException(this.sessionId);

  final String sessionId;
}

class SessionRepository {
  SessionRepository(this._db, this._stamp);

  final AppDatabase _db;
  final WriteStamp _stamp;
  static const _uuid = Uuid();

  late final List<TableInfo<Table, dynamic>> _sessionTables = [
    _db.workoutSessions,
    _db.sessionExercises,
    _db.setEntries,
    _db.exercises,
  ];

  // -------------------------------------------------------------------------
  // Reads
  // -------------------------------------------------------------------------

  Stream<SessionDetails?> watchActive() =>
      _db.watchComposite(_sessionTables, getActive);

  Future<SessionDetails?> getActive() async {
    final session =
        await (_db.select(_db.workoutSessions)
              ..where((t) => t.endedAt.isNull() & t.deleted.equals(false))
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (session == null) return null;
    return (await _load([session])).single;
  }

  Stream<SessionDetails?> watchDetails(String sessionId) =>
      _db.watchComposite(_sessionTables, () => getDetails(sessionId));

  Future<SessionDetails?> getDetails(String sessionId) async {
    final session =
        await (_db.select(_db.workoutSessions)
              ..where((t) => t.id.equals(sessionId) & t.deleted.equals(false)))
            .getSingleOrNull();
    if (session == null) return null;
    return (await _load([session])).single;
  }

  /// Finished sessions, most recent first.
  Stream<List<SessionDetails>> watchHistory() =>
      _db.watchComposite(_sessionTables, getHistory);

  Future<List<SessionDetails>> getHistory() async {
    final sessions =
        await (_db.select(_db.workoutSessions)
              ..where((t) => t.endedAt.isNotNull() & t.deleted.equals(false))
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
            .get();
    return await _load(sessions);
  }

  /// Every completed set of every finished session, oldest first.
  Stream<List<PerformedSet>> watchPerformedSets() =>
      _db.watchComposite(_sessionTables, getPerformedSets);

  Future<List<PerformedSet>> getPerformedSets() async {
    final query =
        _db.select(_db.setEntries).join([
            innerJoin(
              _db.sessionExercises,
              _db.sessionExercises.id.equalsExp(
                _db.setEntries.sessionExerciseId,
              ),
            ),
            innerJoin(
              _db.workoutSessions,
              _db.workoutSessions.id.equalsExp(_db.sessionExercises.sessionId),
            ),
          ])
          ..where(
            _db.setEntries.deleted.equals(false) &
                _db.setEntries.completedAt.isNotNull() &
                _db.sessionExercises.deleted.equals(false) &
                _db.workoutSessions.deleted.equals(false) &
                _db.workoutSessions.endedAt.isNotNull(),
          )
          ..orderBy([
            OrderingTerm.asc(_db.workoutSessions.startedAt),
            OrderingTerm.asc(_db.sessionExercises.orderIndex),
            OrderingTerm.asc(_db.setEntries.setIndex),
          ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        _performed(
          row.readTable(_db.setEntries),
          row.readTable(_db.sessionExercises),
          row.readTable(_db.workoutSessions),
        ),
    ];
  }

  static PerformedSet _performed(
    SetEntry set,
    SessionExercise entry,
    WorkoutSession session,
  ) {
    return PerformedSet(
      setId: set.id,
      sessionId: session.id,
      sessionStartedAt: session.startedAt,
      exerciseId: entry.exerciseId,
      setIndex: set.setIndex,
      isWarmup: set.isWarmup,
      reps: set.reps,
      weightKg: set.weightKg,
      durationSeconds: set.durationSeconds,
      distanceMeters: set.distanceMeters,
    );
  }

  /// Completed sets of [exerciseId] in the most recent finished session that
  /// contains it, ordered by set index. Empty if never done.
  Future<List<SetEntry>> getLastPerformance(String exerciseId) async {
    final last =
        await (_db.select(_db.sessionExercises).join([
                innerJoin(
                  _db.workoutSessions,
                  _db.workoutSessions.id.equalsExp(
                    _db.sessionExercises.sessionId,
                  ),
                ),
              ])
              ..where(
                _db.sessionExercises.exerciseId.equals(exerciseId) &
                    _db.sessionExercises.deleted.equals(false) &
                    _db.workoutSessions.deleted.equals(false) &
                    _db.workoutSessions.endedAt.isNotNull(),
              )
              ..orderBy([OrderingTerm.desc(_db.workoutSessions.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    if (last == null) return const [];
    final entry = last.readTable(_db.sessionExercises);
    return await (_db.select(_db.setEntries)
          ..where(
            (t) =>
                t.sessionExerciseId.equals(entry.id) &
                t.deleted.equals(false) &
                t.completedAt.isNotNull(),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.setIndex)]))
        .get();
  }

  Future<List<SessionDetails>> _load(List<WorkoutSession> sessions) async {
    if (sessions.isEmpty) return const [];
    final sessionIds = sessions.map((s) => s.id).toList();
    final entryRows =
        await (_db.select(_db.sessionExercises).join([
                innerJoin(
                  _db.exercises,
                  _db.exercises.id.equalsExp(_db.sessionExercises.exerciseId),
                ),
              ])
              ..where(
                _db.sessionExercises.sessionId.isIn(sessionIds) &
                    _db.sessionExercises.deleted.equals(false),
              )
              ..orderBy([OrderingTerm.asc(_db.sessionExercises.orderIndex)]))
            .get();
    final entryIds = [
      for (final row in entryRows) row.readTable(_db.sessionExercises).id,
    ];
    final sets = entryIds.isEmpty
        ? const <SetEntry>[]
        : await (_db.select(_db.setEntries)
                ..where(
                  (t) =>
                      t.sessionExerciseId.isIn(entryIds) &
                      t.deleted.equals(false),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.setIndex)]))
              .get();

    final setsByEntry = <String, List<SetEntry>>{};
    for (final set in sets) {
      (setsByEntry[set.sessionExerciseId] ??= []).add(set);
    }
    final exercisesBySession = <String, List<SessionExerciseDetails>>{};
    for (final row in entryRows) {
      final entry = row.readTable(_db.sessionExercises);
      (exercisesBySession[entry.sessionId] ??= []).add(
        SessionExerciseDetails(
          entry: entry,
          exercise: row.readTable(_db.exercises),
          sets: setsByEntry[entry.id] ?? const [],
        ),
      );
    }
    return [
      for (final session in sessions)
        SessionDetails(
          session: session,
          exercises: exercisesBySession[session.id] ?? const [],
        ),
    ];
  }

  // -------------------------------------------------------------------------
  // Session lifecycle
  // -------------------------------------------------------------------------

  /// Starts a session and copies the plan into it. Only one session can be
  /// in progress at a time.
  Future<String> start({
    required List<PlannedSessionExercise> plan,
    String? programDayId,
    String? name,
  }) {
    return _db.transaction(() async {
      final active =
          await (_db.select(_db.workoutSessions)
                ..where((t) => t.endedAt.isNull() & t.deleted.equals(false))
                ..limit(1))
              .getSingleOrNull();
      if (active != null) throw ActiveSessionExistsException(active.id);

      final now = _stamp.now();
      final sessionId = _uuid.v4();
      await _db
          .into(_db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              id: Value(sessionId),
              programDayId: Value(programDayId),
              name: Value(name),
              startedAt: now,
              createdAt: Value(now),
              updatedAt: Value(now),
              lastModifiedBy: Value(_stamp.deviceId),
            ),
          );
      var order = 0;
      for (final planned in plan) {
        order += orderStep;
        await _insertExercise(sessionId, planned, order, now);
      }
      return sessionId;
    });
  }

  Future<String> _insertExercise(
    String sessionId,
    PlannedSessionExercise planned,
    int orderIndex,
    DateTime now,
  ) async {
    final entryId = _uuid.v4();
    await _db
        .into(_db.sessionExercises)
        .insert(
          SessionExercisesCompanion.insert(
            id: Value(entryId),
            sessionId: sessionId,
            exerciseId: planned.exerciseId,
            programExerciseId: Value(planned.programExerciseId),
            orderIndex: orderIndex,
            notes: Value(planned.notes),
            targetRepsMin: Value(planned.targetRepsMin),
            targetRepsMax: Value(planned.targetRepsMax),
            restSeconds: Value(planned.restSeconds),
            createdAt: Value(now),
            updatedAt: Value(now),
            lastModifiedBy: Value(_stamp.deviceId),
          ),
        );
    for (final (index, values) in planned.sets.indexed) {
      await _db
          .into(_db.setEntries)
          .insert(_newSet(entryId, index, values, now));
    }
    return entryId;
  }

  SetEntriesCompanion _newSet(
    String entryId,
    int setIndex,
    SetValues values,
    DateTime now,
  ) {
    return SetEntriesCompanion.insert(
      sessionExerciseId: entryId,
      setIndex: setIndex,
      reps: Value(values.reps),
      weightKg: Value(values.weightKg),
      durationSeconds: Value(values.durationSeconds),
      distanceMeters: Value(values.distanceMeters),
      isWarmup: Value(values.isWarmup),
      createdAt: Value(now),
      updatedAt: Value(now),
      lastModifiedBy: Value(_stamp.deviceId),
    );
  }

  /// Ends the session. Sets never completed are dropped, and so are
  /// exercises left without any completed set.
  Future<void> finish(String sessionId, {String? notes}) {
    return _db.transaction(() async {
      final details = await getDetails(sessionId);
      if (details == null) return;
      final now = _stamp.now();
      for (final exercise in details.exercises) {
        final pending = exercise.sets.where((s) => s.completedAt == null);
        for (final set in pending) {
          await _softDeleteSet(set.id, now);
        }
        if (pending.length == exercise.sets.length) {
          await _softDeleteEntry(exercise.entry.id, now);
        }
      }
      final session = details.session;
      await _writeSession(
        sessionId,
        WorkoutSessionsCompanion(
          endedAt: Value(now),
          restEndsAt: const Value(null),
          pausedAt: const Value(null),
          pausedSeconds: Value(_pausedSecondsAt(session, now)),
          notes: notes == null ? const Value.absent() : Value(notes),
        ),
        now,
      );
    });
  }

  /// Soft-deletes a session with its exercises and sets (discard an active
  /// session, or delete one from the history).
  Future<void> delete(String sessionId) {
    return _db.transaction(() async {
      final details = await getDetails(sessionId);
      if (details == null) return;
      final now = _stamp.now();
      for (final exercise in details.exercises) {
        for (final set in exercise.sets) {
          await _softDeleteSet(set.id, now);
        }
        await _softDeleteEntry(exercise.entry.id, now);
      }
      await _writeSession(
        sessionId,
        const WorkoutSessionsCompanion(deleted: Value(true)),
        now,
      );
    });
  }

  Future<void> pause(String sessionId) {
    final now = _stamp.now();
    return _writeSession(
      sessionId,
      WorkoutSessionsCompanion(pausedAt: Value(now)),
      now,
    );
  }

  Future<void> resume(String sessionId) {
    return _db.transaction(() async {
      final details = await getDetails(sessionId);
      if (details == null) return;
      final now = _stamp.now();
      final session = details.session;
      final pausedAt = session.pausedAt;
      if (pausedAt == null) return;
      final pause = now.difference(pausedAt);
      await _writeSession(
        sessionId,
        WorkoutSessionsCompanion(
          pausedAt: const Value(null),
          pausedSeconds: Value(session.pausedSeconds + pause.inSeconds),
          // The rest does not run while paused.
          restEndsAt: session.restEndsAt == null
              ? const Value.absent()
              : Value(session.restEndsAt!.add(pause)),
        ),
        now,
      );
    });
  }

  static int _pausedSecondsAt(WorkoutSession session, DateTime now) {
    final pausedAt = session.pausedAt;
    final current = pausedAt == null ? 0 : now.difference(pausedAt).inSeconds;
    return session.pausedSeconds + current;
  }

  Future<void> setRestEndsAt(String sessionId, DateTime? endsAt) {
    return _writeSession(
      sessionId,
      WorkoutSessionsCompanion(
        restEndsAt: Value(endsAt == null ? null : normalizeTimestamp(endsAt)),
      ),
      _stamp.now(),
    );
  }

  Future<void> updateSessionNotes(String sessionId, String? notes) {
    return _writeSession(
      sessionId,
      WorkoutSessionsCompanion(notes: Value(_blankToNull(notes))),
      _stamp.now(),
    );
  }

  Future<void> _writeSession(
    String sessionId,
    WorkoutSessionsCompanion values,
    DateTime now,
  ) {
    return (_db.update(
      _db.workoutSessions,
    )..where((t) => t.id.equals(sessionId))).write(
      values.copyWith(
        updatedAt: Value(now),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Exercises and sets
  // -------------------------------------------------------------------------

  /// Records a set as done and, in the same transaction, the rest that
  /// follows it.
  Future<void> completeSet(
    String setId,
    SetValues values, {
    required String sessionId,
    DateTime? restEndsAt,
  }) {
    return _db.transaction(() async {
      final now = _stamp.now();
      await _writeSet(
        setId,
        _values(values).copyWith(completedAt: Value(now)),
        now,
      );
      await _writeSession(
        sessionId,
        WorkoutSessionsCompanion(
          restEndsAt: Value(
            restEndsAt == null ? null : normalizeTimestamp(restEndsAt),
          ),
        ),
        now,
      );
    });
  }

  /// Marks a completed set as not done again.
  Future<void> uncompleteSet(String setId) {
    return _writeSet(
      setId,
      const SetEntriesCompanion(completedAt: Value(null)),
      _stamp.now(),
    );
  }

  /// Edits the values of a set without changing whether it is done.
  Future<void> updateSet(String setId, SetValues values) =>
      _writeSet(setId, _values(values), _stamp.now());

  /// Appends a set copying the values of the last one.
  Future<String> addSet(String sessionExerciseId) {
    return _db.transaction(() async {
      final sets =
          await (_db.select(_db.setEntries)
                ..where(
                  (t) =>
                      t.sessionExerciseId.equals(sessionExerciseId) &
                      t.deleted.equals(false),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.setIndex)]))
              .get();
      final last = sets.lastOrNull;
      final values = last == null
          ? const SetValues()
          : SetValues(
              reps: last.reps,
              weightKg: last.weightKg,
              durationSeconds: last.durationSeconds,
              distanceMeters: last.distanceMeters,
            );
      final id = _uuid.v4();
      await _db
          .into(_db.setEntries)
          .insert(
            _newSet(
              sessionExerciseId,
              (last?.setIndex ?? -1) + 1,
              values,
              _stamp.now(),
            ).copyWith(id: Value(id)),
          );
      return id;
    });
  }

  Future<void> removeSet(String setId) => _softDeleteSet(setId, _stamp.now());

  Future<String> addExercise(String sessionId, PlannedSessionExercise planned) {
    return _db.transaction(() async {
      final entries =
          await (_db.select(_db.sessionExercises)
                ..where(
                  (t) =>
                      t.sessionId.equals(sessionId) & t.deleted.equals(false),
                )
                ..orderBy([(t) => OrderingTerm.desc(t.orderIndex)])
                ..limit(1))
              .getSingleOrNull();
      return await _insertExercise(
        sessionId,
        planned,
        nextOrderIndex(entries?.orderIndex),
        _stamp.now(),
      );
    });
  }

  Future<void> removeExercise(String sessionExerciseId) {
    return _db.transaction(() async {
      final now = _stamp.now();
      await (_db.update(_db.setEntries)..where(
            (t) =>
                t.sessionExerciseId.equals(sessionExerciseId) &
                t.deleted.equals(false),
          ))
          .write(
            SetEntriesCompanion(
              deleted: const Value(true),
              updatedAt: Value(now),
              lastModifiedBy: Value(_stamp.deviceId),
            ),
          );
      await _softDeleteEntry(sessionExerciseId, now);
    });
  }

  Future<void> moveExercise(String sessionId, int oldIndex, int newIndex) {
    return _db.transaction(() async {
      final entries =
          await (_db.select(_db.sessionExercises)
                ..where(
                  (t) =>
                      t.sessionId.equals(sessionId) & t.deleted.equals(false),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
              .get();
      final changes = moveOrderIndex(
        entries.map((e) => e.orderIndex).toList(),
        oldIndex,
        newIndex,
      );
      final now = _stamp.now();
      for (final MapEntry(key: position, value: index) in changes.entries) {
        await _writeEntry(
          entries[position].id,
          SessionExercisesCompanion(orderIndex: Value(index)),
          now,
        );
      }
    });
  }

  Future<void> updateExerciseNotes(String sessionExerciseId, String? notes) {
    return _writeEntry(
      sessionExerciseId,
      SessionExercisesCompanion(notes: Value(_blankToNull(notes))),
      _stamp.now(),
    );
  }

  static SetEntriesCompanion _values(SetValues values) {
    return SetEntriesCompanion(
      reps: Value(values.reps),
      weightKg: Value(values.weightKg),
      durationSeconds: Value(values.durationSeconds),
      distanceMeters: Value(values.distanceMeters),
      isWarmup: Value(values.isWarmup),
    );
  }

  Future<void> _writeSet(
    String setId,
    SetEntriesCompanion values,
    DateTime now,
  ) {
    return (_db.update(_db.setEntries)..where((t) => t.id.equals(setId))).write(
      values.copyWith(
        updatedAt: Value(now),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }

  Future<void> _writeEntry(
    String entryId,
    SessionExercisesCompanion values,
    DateTime now,
  ) {
    return (_db.update(
      _db.sessionExercises,
    )..where((t) => t.id.equals(entryId))).write(
      values.copyWith(
        updatedAt: Value(now),
        lastModifiedBy: Value(_stamp.deviceId),
      ),
    );
  }

  Future<void> _softDeleteSet(String setId, DateTime now) =>
      _writeSet(setId, const SetEntriesCompanion(deleted: Value(true)), now);

  Future<void> _softDeleteEntry(String entryId, DateTime now) => _writeEntry(
    entryId,
    const SessionExercisesCompanion(deleted: Value(true)),
    now,
  );

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
