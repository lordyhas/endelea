import 'package:endelea/data/database.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/session/session_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/builders.dart';

final _start = DateTime.utc(2026, 11, 6, 18);

WorkoutSession _session({
  DateTime? endedAt,
  DateTime? pausedAt,
  int pausedSeconds = 0,
}) {
  return WorkoutSession(
    id: 's',
    createdAt: _start,
    updatedAt: _start,
    deleted: false,
    lastModifiedBy: 'device-a',
    startedAt: _start,
    endedAt: endedAt,
    pausedAt: pausedAt,
    pausedSeconds: pausedSeconds,
  );
}

SessionExerciseDetails _exercise(String id, List<bool> done) {
  return SessionExerciseDetails(
    entry: SessionExercise(
      id: 'e-$id',
      createdAt: _start,
      updatedAt: _start,
      deleted: false,
      lastModifiedBy: 'device-a',
      sessionId: 's',
      exerciseId: id,
      orderIndex: 10,
      restSeconds: 90,
    ),
    exercise: exercise(id),
    sets: [
      for (final (index, isDone) in done.indexed)
        SetEntry(
          id: '$id-$index',
          createdAt: _start,
          updatedAt: _start,
          deleted: false,
          lastModifiedBy: 'device-a',
          sessionExerciseId: 'e-$id',
          setIndex: index,
          isWarmup: false,
          completedAt: isDone ? _start : null,
          weightKg: 60,
          reps: 8,
        ),
    ],
  );
}

void main() {
  final details = SessionDetails(
    session: _session(),
    exercises: [
      _exercise('a', [true, true]),
      _exercise('b', [true, false]),
      _exercise('c', [false]),
    ],
  );

  test('pending set of an exercise', () {
    expect(pendingSetIndex(details.exercises[0]), isNull);
    expect(pendingSetIndex(details.exercises[1]), 1);
  });

  test('initial position is the first exercise with a set left', () {
    expect(initialPosition(details), const SessionPosition(1, 1));
  });

  test('next pending exercise wraps around', () {
    expect(nextPendingExercise(details, from: 1), 2);
    expect(nextPendingExercise(details, from: 2), 1);
    final done = SessionDetails(
      session: _session(),
      exercises: [
        _exercise('a', [true]),
      ],
    );
    expect(nextPendingExercise(done, from: 0), isNull);
    expect(isSessionComplete(done), isTrue);
    expect(isSessionComplete(details), isFalse);
  });

  test('positionAt clamps the index', () {
    expect(positionAt(details, 9), const SessionPosition(2, 0));
    expect(
      positionAt(SessionDetails(session: _session(), exercises: const []), 0),
      const SessionPosition(0, null),
    );
  });

  test('pending sets besides one', () {
    final last = SessionDetails(
      session: _session(),
      exercises: [
        _exercise('a', [true, false]),
      ],
    );
    expect(hasPendingSetBesides(last, 'a-1'), isFalse);
    expect(hasPendingSetBesides(details, 'c-0'), isTrue);
  });

  test('elapsed time excludes pauses', () {
    final now = _start.add(const Duration(minutes: 50));
    expect(
      sessionElapsed(_session(pausedSeconds: 600), now),
      const Duration(minutes: 40),
    );
    expect(
      sessionElapsed(
        _session(pausedAt: _start.add(const Duration(minutes: 20))),
        now,
      ),
      const Duration(minutes: 20),
    );
    expect(
      sessionElapsed(
        _session(endedAt: _start.add(const Duration(minutes: 45))),
        now,
      ),
      const Duration(minutes: 45),
    );
  });

  test('rest remaining is never negative', () {
    final endsAt = _start.add(const Duration(seconds: 90));
    expect(restRemaining(endsAt, _start), const Duration(seconds: 90));
    expect(
      restRemaining(endsAt, _start.add(const Duration(minutes: 5))),
      Duration.zero,
    );
  });

  test('performed sets of an exercise', () {
    final sets = performedSetsOf(details.session, details.exercises[1]);
    expect(sets.map((s) => s.setId), ['b-0']);
    expect(sets.single.exerciseId, 'b');
  });
}
