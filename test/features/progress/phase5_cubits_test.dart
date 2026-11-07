import 'package:bloc_test/bloc_test.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/body_repository.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/personal_records.dart';
import 'package:endelea/domain/progress/stats.dart';
import 'package:endelea/features/body/bloc/body_cubit.dart';
import 'package:endelea/features/history/bloc/history_cubit.dart';
import 'package:endelea/features/history/bloc/session_detail_cubit.dart';
import 'package:endelea/features/home/bloc/home_cubit.dart';
import 'package:endelea/features/progress/bloc/progress_cubit.dart';
import 'package:endelea/features/session/bloc/session_start_cubit.dart';
import 'package:endelea/features/session/bloc/session_summary_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mocks.dart';

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late SessionRepository sessions;
  late ProgramRepository programs;
  late ExerciseRepository exercises;
  late BodyRepository body;
  late String dayId;
  final bench = builtInExerciseId('bench_press');

  /// A finished session of bench 3 × 8 at [weight], [daysAgo] days ago.
  Future<String> doSession(double weight, {required int daysAgo}) async {
    clock.time = DateTime(2026, 11, 20, 18).subtract(Duration(days: daysAgo));
    final id = await sessions.start(
      programDayId: dayId,
      name: 'Push',
      plan: [
        PlannedSessionExercise(
          exerciseId: bench,
          restSeconds: 90,
          sets: List.filled(3, SetValues(reps: 8, weightKg: weight)),
        ),
      ],
    );
    final details = await sessions.getActive();
    for (final set in details!.exercises.single.sets) {
      await sessions.completeSet(
        set.id,
        SetValues(reps: 8, weightKg: weight),
        sessionId: id,
      );
    }
    clock.advance(const Duration(minutes: 45));
    await sessions.finish(id);
    return id;
  }

  setUp(() async {
    db = memoryDatabase();
    clock = FakeClock(DateTime(2026, 11, 20, 18));
    final stamp = testStamp(clock);
    sessions = SessionRepository(db, stamp);
    programs = ProgramRepository(db, stamp);
    exercises = ExerciseRepository(db, stamp);
    body = BodyRepository(db, stamp);
    await exercises.seedBuiltIns();
    final program = await programs.createProgram('PPL');
    dayId = await programs.addDay(program, 'Push');
    await programs.addExercises(dayId, [
      bench,
    ], defaults: const ExerciseTargets(sets: 3, restSeconds: 90));
  });

  tearDown(() => db.close());

  test('HistoryCubit lists sessions with stats and records', () async {
    await doSession(60, daysAgo: 7);
    await doSession(65, daysAgo: 3);
    final cubit = HistoryCubit(sessions, exercises);
    final loaded = await cubit.stream.firstWhere(
      (s) => s is HistoryLoaded,
    ) as HistoryLoaded;
    expect(loaded.items, hasLength(2));
    final latest = loaded.items.first;
    expect(latest.details.session.startedAt.day, 17);
    expect(latest.stats.volumeKg, 65 * 8 * 3);
    expect(latest.stats.setCount, 3);
    expect(latest.stats.duration, const Duration(minutes: 45));
    // Heavier: max weight, 1RM and session volume.
    expect(latest.stats.recordCount, 3);
    expect(loaded.items.last.stats.recordCount, 0);
    await cubit.close();
  });

  test('SessionDetailCubit edits a past set and deletes', () async {
    final id = await doSession(60, daysAgo: 1);
    final cubit = SessionDetailCubit(sessions, id);
    final loaded = await cubit.stream.firstWhere(
      (s) => s is SessionDetailLoaded,
    ) as SessionDetailLoaded;
    final set = loaded.details.exercises.single.sets.first;
    await cubit.updateSet(set.id, const SetValues(reps: 10, weightKg: 62.5));
    await cubit.stream.firstWhere(
      (s) =>
          s is SessionDetailLoaded &&
          s.details.exercises.single.sets.first.weightKg == 62.5,
    );
    await cubit.updateNotes('Felt strong');
    await cubit.delete();
    await cubit.stream.firstWhere((s) => s is SessionDetailNotFound);
    expect(await sessions.getHistory(), isEmpty);
    await cubit.close();
  });

  test('ProgressCubit filters by period', () async {
    await doSession(60, daysAgo: 60);
    await doSession(70, daysAgo: 2);
    await body.add(measuredAt: clock.now(), bodyWeightKg: 80);
    final cubit = ProgressCubit(
      sessions: sessions,
      exercises: exercises,
      body: body,
      clock: clock,
    );
    var loaded = await cubit.stream.firstWhere(
      (s) => s is ProgressLoaded && s.latestBody != null,
    ) as ProgressLoaded;
    expect(loaded.period, ProgressPeriod.weeks4);
    expect(loaded.sessionCount, 1);
    expect(loaded.volumeKg, 70 * 24);
    expect(loaded.recordCount, 3);
    expect(loaded.topExercises.single.exercise.id, bench);
    expect(loaded.weeks, hasLength(4));
    expect(loaded.latestBody!.bodyWeightKg, 80);

    cubit.setPeriod(ProgressPeriod.all);
    loaded = cubit.state as ProgressLoaded;
    expect(loaded.sessionCount, 2);
    expect(loaded.volumeKg, (60 + 70) * 24);
    await cubit.close();
  });

  test('HomeCubit: next day, week stats, streak and records', () async {
    await doSession(60, daysAgo: 7);
    await doSession(62.5, daysAgo: 1);
    clock.time = DateTime(2026, 11, 20, 18);
    final cubit = HomeCubit(
      programs: programs,
      sessions: sessions,
      exercises: exercises,
      clock: clock,
    );
    final loaded =
        await cubit.stream.firstWhere((s) => s is HomeLoaded) as HomeLoaded;
    expect(loaded.hasPrograms, isTrue);
    expect(loaded.next!.day.day.id, dayId);
    expect(loaded.sessionsThisWeek, 1);
    expect(loaded.volumeThisWeekKg, 62.5 * 24);
    expect(loaded.weekStreak, 2);
    expect(loaded.lastRecords, hasLength(3));
    expect(
      loaded.lastRecords.map((r) => r.event.type),
      containsAll([RecordType.maxWeight, RecordType.estimatedOneRepMax]),
    );
    await cubit.close();
  });

  test('SessionStartCubit offers the next day and every day', () async {
    final cubit = SessionStartCubit(programs);
    final loaded = await cubit.stream.firstWhere(
      (s) => s is SessionStartLoaded,
    ) as SessionStartLoaded;
    expect(loaded.next!.day.day.id, dayId);
    expect(loaded.days.single.exerciseCount, 1);
    await cubit.close();
  });

  test('SessionSummaryCubit compares with the same day last time', () async {
    await doSession(60, daysAgo: 7);
    final id = await doSession(65, daysAgo: 2);
    final cubit = SessionSummaryCubit(sessions, id);
    await cubit.load();
    final summary = (cubit.state as SessionSummaryLoaded).summary;
    expect(summary.volumeKg, 65 * 24);
    expect(summary.setCount, 3);
    expect(summary.previous!.volumeKg, 60 * 24);
    expect(
      summary.records.map((r) => r.type),
      containsAll([RecordType.maxWeight, RecordType.sessionVolume]),
    );
    await cubit.saveNotes('Good');
    expect((await sessions.getDetails(id))!.session.notes, 'Good');
    await cubit.close();
  });

  group('BodyCubit', () {
    late MockBodyRepository repository;
    setUp(() => repository = MockBodyRepository());

    blocTest<BodyCubit, BodyState>(
      'lists measurements and delegates changes',
      build: () {
        when(() => repository.watchAll())
            .thenAnswer((_) => Stream.value(const []));
        when(
          () => repository.add(
            measuredAt: any(named: 'measuredAt'),
            bodyWeightKg: 80,
          ),
        ).thenAnswer((_) async => 'm');
        when(() => repository.delete('m')).thenAnswer((_) async {});
        return BodyCubit(repository);
      },
      act: (cubit) async {
        await cubit.add(measuredAt: DateTime(2026, 11, 20), bodyWeightKg: 80);
        await cubit.delete('m');
      },
      expect: () => [const BodyLoaded([])],
      verify: (_) => verify(() => repository.delete('m')).called(1),
    );
  });
}
