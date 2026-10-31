import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/data/repositories/write_stamp.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

const _targets = ExerciseTargets(
  sets: 4,
  repsMin: 8,
  repsMax: 10,
  restSeconds: 90,
);

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late ProgramRepository repo;
  late SessionRepository sessions;

  setUp(() async {
    db = memoryDatabase();
    clock = FakeClock();
    final stamp = testStamp(clock);
    repo = ProgramRepository(db, stamp);
    sessions = SessionRepository(db, stamp);
    await ExerciseRepository(db, stamp).seedBuiltIns();
  });

  tearDown(() => db.close());

  final bench = builtInExerciseId('bench_press');
  final squat = builtInExerciseId('back_squat');
  final row = builtInExerciseId('barbell_row');

  test('the first program becomes active, the next ones do not', () async {
    final a = await repo.createProgram('PPL');
    final b = await repo.createProgram('Full body');
    final summaries = await repo.getSummaries();
    expect(summaries.map((s) => s.program.id), [a, b]);
    expect(summaries.map((s) => s.program.isActive), [true, false]);

    await repo.activate(b);
    final after = await repo.getSummaries();
    expect(after.map((s) => s.program.isActive), [false, true]);
  });

  test('days and planned exercises keep their order', () async {
    final program = await repo.createProgram('PPL');
    final push = await repo.addDay(program, 'Push');
    final pull = await repo.addDay(program, 'Pull');
    final legs = await repo.addDay(program, 'Legs');
    await repo.moveDay(program, 2, 0);

    final details = await repo.getDetails(program);
    expect(details!.days.map((d) => d.day.id), [legs, push, pull]);

    await repo.addExercises(push, [bench, squat, row], defaults: _targets);
    await repo.movePlannedExercise(push, 0, 2);
    final day = await repo.getDay(push);
    expect(day!.exercises.map((e) => e.exercise.id), [squat, row, bench]);
    expect(day.exercises.first.plan.targetSets, 4);
    expect((await repo.getDetails(program))!.days[1].exerciseCount, 3);
  });

  test('updating targets stamps the row', () async {
    final program = await repo.createProgram('PPL');
    final day = await repo.addDay(program, 'Push');
    await repo.addExercises(day, [bench], defaults: _targets);
    final planned = (await repo.getPlannedExercises(day)).single.plan;

    clock.advance(const Duration(hours: 1));
    await repo.updateTargets(
      planned.id,
      const ExerciseTargets(sets: 5, repsMin: 5, repsMax: 5, restSeconds: 180),
    );
    final updated = (await repo.getPlannedExercises(day)).single.plan;
    expect(updated.targetSets, 5);
    expect(updated.restSeconds, 180);
    expect(updated.updatedAt, normalizeTimestamp(clock.now()));
    expect(updated.lastModifiedBy, 'device-a');
  });

  test('deleting a program soft-deletes its days and exercises', () async {
    final program = await repo.createProgram('PPL');
    final day = await repo.addDay(program, 'Push');
    await repo.addExercises(day, [bench], defaults: _targets);

    await repo.deleteProgram(program);
    expect(await repo.getSummaries(), isEmpty);
    expect(await repo.getDay(day), isNull);
    final rows = await db.select(db.programExercises).get();
    expect(rows.single.deleted, isTrue);
  });

  test('duplicate copies days and targets with new ids', () async {
    final program = await repo.createProgram('PPL');
    final day = await repo.addDay(program, 'Push');
    await repo.addExercises(day, [bench, squat], defaults: _targets);

    final copy = await repo.duplicate(program, name: 'PPL (copy)');
    final details = await repo.getDetails(copy);
    expect(details!.program.name, 'PPL (copy)');
    expect(details.program.isActive, isFalse);
    expect(details.days.single.day.id, isNot(day));
    final planned = await repo.getPlannedExercises(details.days.single.day.id);
    expect(planned.map((p) => p.exercise.id), [bench, squat]);
  });

  test('next day rotates after the last finished session', () async {
    final program = await repo.createProgram('PPL');
    final a = await repo.addDay(program, 'A');
    final b = await repo.addDay(program, 'B');
    expect((await repo.getNextDay())!.day.day.id, a);

    Future<void> doDay(String dayId) async {
      final id = await sessions.start(plan: const [], programDayId: dayId);
      clock.advance(const Duration(hours: 1));
      await sessions.finish(id);
      clock.advance(const Duration(days: 1));
    }

    await doDay(a);
    expect((await repo.getNextDay())!.day.day.id, b);
    await doDay(b);
    expect((await repo.getNextDay())!.day.day.id, a);
    expect((await repo.getSummaries()).single.lastSessionAt, isNotNull);
  });

  test('no next day without an active program', () async {
    expect(await repo.getNextDay(), isNull);
  });

  test('watchSummaries emits on change', () async {
    final expectation = expectLater(
      repo.watchSummaries().map((s) => s.length),
      emitsInOrder([0, 1]),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await repo.createProgram('PPL');
    await expectation;
  });
}
