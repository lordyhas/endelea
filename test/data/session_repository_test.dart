import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/data/repositories/write_stamp.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late SessionRepository repo;

  final bench = builtInExerciseId('bench_press');
  final squat = builtInExerciseId('back_squat');

  PlannedSessionExercise planned(String exerciseId, {int sets = 3}) {
    return PlannedSessionExercise(
      exerciseId: exerciseId,
      sets: List.filled(sets, const SetValues(reps: 8, weightKg: 60)),
      targetRepsMin: 8,
      targetRepsMax: 10,
      restSeconds: 90,
    );
  }

  Future<SessionDetails> active() async => (await repo.getActive())!;

  setUp(() async {
    db = memoryDatabase();
    clock = FakeClock();
    repo = SessionRepository(db, testStamp(clock));
    await ExerciseRepository(db, testStamp(clock)).seedBuiltIns();
  });

  tearDown(() => db.close());

  test('start copies the plan with pre-filled sets', () async {
    final id = await repo.start(
      plan: [planned(bench), planned(squat, sets: 2)],
    );
    final session = await active();
    expect(session.session.id, id);
    expect(session.exercises.map((e) => e.exercise.id), [bench, squat]);
    final first = session.exercises.first;
    expect(first.sets, hasLength(3));
    expect(first.sets.first.weightKg, 60);
    expect(first.entry.targetRepsMax, 10);
    expect(first.sets.every((s) => s.completedAt == null), isTrue);
  });

  test('only one session at a time', () async {
    final id = await repo.start(plan: [planned(bench)]);
    await expectLater(
      repo.start(plan: [planned(squat)]),
      throwsA(
        isA<ActiveSessionExistsException>().having(
          (e) => e.sessionId,
          'sessionId',
          id,
        ),
      ),
    );
  });

  test('completing a set stores the values and the rest end', () async {
    final id = await repo.start(plan: [planned(bench)]);
    final set = (await active()).exercises.first.sets.first;
    clock.advance(const Duration(minutes: 2));
    final restEndsAt = clock.now().add(const Duration(seconds: 90));
    await repo.completeSet(
      set.id,
      const SetValues(reps: 10, weightKg: 62.5),
      sessionId: id,
      restEndsAt: restEndsAt,
    );

    final session = await active();
    final done = session.exercises.first.sets.first;
    expect(done.reps, 10);
    expect(done.weightKg, 62.5);
    expect(done.completedAt, normalizeTimestamp(clock.now()));
    expect(session.session.restEndsAt!.isAtSameMomentAs(restEndsAt), isTrue);

    await repo.uncompleteSet(set.id);
    final undone = (await active()).exercises.first.sets.first;
    expect(undone.completedAt, isNull);
  });

  test('add and remove sets', () async {
    await repo.start(plan: [planned(bench, sets: 1)]);
    final entry = (await active()).exercises.first;
    final added = await repo.addSet(entry.entry.id);
    var sets = (await active()).exercises.first.sets;
    expect(sets.map((s) => s.setIndex), [0, 1]);
    expect(sets.last.weightKg, 60);

    await repo.removeSet(added);
    sets = (await active()).exercises.first.sets;
    expect(sets, hasLength(1));
  });

  test('add, move and remove exercises', () async {
    final id = await repo.start(plan: [planned(bench)]);
    await repo.addExercise(id, planned(squat));
    await repo.moveExercise(id, 1, 0);
    var session = await active();
    expect(session.exercises.map((e) => e.exercise.id), [squat, bench]);

    await repo.removeExercise(session.exercises.first.entry.id);
    session = await active();
    expect(session.exercises.map((e) => e.exercise.id), [bench]);
  });

  test('pause shifts the rest and counts paused time', () async {
    final id = await repo.start(plan: [planned(bench)]);
    final restEndsAt = clock.now().add(const Duration(seconds: 60));
    await repo.setRestEndsAt(id, restEndsAt);

    await repo.pause(id);
    clock.advance(const Duration(minutes: 5));
    await repo.resume(id);

    final session = (await active()).session;
    expect(session.pausedAt, isNull);
    expect(session.pausedSeconds, 300);
    expect(
      session.restEndsAt!.isAtSameMomentAs(
        restEndsAt.add(const Duration(minutes: 5)),
      ),
      isTrue,
    );
  });

  test('finish drops pending sets and empty exercises', () async {
    final id = await repo.start(plan: [planned(bench), planned(squat)]);
    final set = (await active()).exercises.first.sets.first;
    await repo.completeSet(
      set.id,
      const SetValues(reps: 8, weightKg: 60),
      sessionId: id,
    );
    clock.advance(const Duration(minutes: 45));
    await repo.finish(id, notes: 'Good');

    expect(await repo.getActive(), isNull);
    final session = (await repo.getHistory()).single;
    expect(session.session.notes, 'Good');
    expect(session.session.endedAt, normalizeTimestamp(clock.now()));
    expect(session.exercises.single.exercise.id, bench);
    expect(session.exercises.single.sets, hasLength(1));
  });

  test('last performance and performed sets read finished sessions', () async {
    final first = await repo.start(plan: [planned(bench, sets: 2)]);
    for (final set in (await active()).exercises.first.sets) {
      await repo.completeSet(
        set.id,
        const SetValues(reps: 8, weightKg: 70),
        sessionId: first,
      );
    }
    expect(await repo.getLastPerformance(bench), isEmpty);
    await repo.finish(first);

    final last = await repo.getLastPerformance(bench);
    expect(last.map((s) => s.weightKg), [70, 70]);
    final performed = await repo.getPerformedSets();
    expect(performed, hasLength(2));
    expect(performed.first.exerciseId, bench);
    expect(performed.first.sessionId, first);
  });

  test('delete removes a session from the history', () async {
    final id = await repo.start(plan: [planned(bench)]);
    await repo.delete(id);
    expect(await repo.getActive(), isNull);
    expect(await repo.getHistory(), isEmpty);
    final sets = await db.select(db.setEntries).get();
    expect(sets.every((s) => s.deleted), isTrue);
  });
}
