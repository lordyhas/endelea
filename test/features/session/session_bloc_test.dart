import 'package:bloc_test/bloc_test.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/personal_records.dart';
import 'package:endelea/domain/session/session_rules.dart';
import 'package:endelea/features/session/bloc/session_bloc.dart';
import 'package:endelea/features/session/data/session_effects.dart';
import 'package:endelea/features/settings/data/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

class RecordingAlerts implements RestAlerts {
  final scheduled = <DateTime>[];
  int cancels = 0;

  @override
  Future<void> schedule(DateTime endsAt) async => scheduled.add(endsAt);

  @override
  Future<void> cancel() async => cancels++;
}

class RecordingHaptics implements SessionHaptics {
  int sets = 0;
  int rests = 0;

  @override
  Future<void> setCompleted() async => sets++;

  @override
  Future<void> restEnded() async => rests++;
}

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late SessionRepository sessions;
  late ProgramRepository programs;
  late RecordingAlerts alerts;
  late RecordingHaptics haptics;
  late String dayId;

  final bench = builtInExerciseId('bench_press');
  final squat = builtInExerciseId('back_squat');

  setUp(() async {
    db = memoryDatabase();
    clock = FakeClock();
    final stamp = testStamp(clock);
    sessions = SessionRepository(db, stamp);
    programs = ProgramRepository(db, stamp);
    alerts = RecordingAlerts();
    haptics = RecordingHaptics();
    await ExerciseRepository(db, stamp).seedBuiltIns();

    final program = await programs.createProgram('PPL');
    dayId = await programs.addDay(program, 'Push');
    await programs.addExercises(
      dayId,
      [bench],
      defaults: const ExerciseTargets(
        sets: 2,
        repsMin: 8,
        repsMax: 10,
        weightKg: 60,
        restSeconds: 90,
      ),
    );
    await programs.addExercises(
      dayId,
      [squat],
      defaults: const ExerciseTargets(
        sets: 1,
        repsMin: 5,
        repsMax: 5,
        weightKg: 100,
        restSeconds: 180,
      ),
    );
  });

  tearDown(() => db.close());

  SessionBloc build() => SessionBloc(
    sessions: sessions,
    programs: programs,
    clock: clock,
    settings: () => const AppSettings(),
    alerts: alerts,
    haptics: haptics,
    // Ticks are sent by hand.
    tick: const Duration(days: 1),
  );

  Future<T> next<T extends SessionState>(SessionBloc bloc) async {
    if (bloc.state is T) return bloc.state as T;
    return await bloc.stream.firstWhere((s) => s is T) as T;
  }

  /// Waits until the bloc has processed everything sent so far.
  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  test('idle without a session in progress', () async {
    final bloc = build();
    await next<SessionIdle>(bloc);
    await bloc.close();
  });

  test('starting a day copies the plan and shows the first set', () async {
    final bloc = build()..add(SessionStarted(programDayId: dayId));
    final active = await next<SessionActive>(bloc);

    expect(active.details.session.name, 'Push');
    expect(active.details.exercises.map((e) => e.exercise.id), [bench, squat]);
    expect(active.position.exerciseIndex, 0);
    expect(active.position.setIndex, 0);
    expect(active.currentSet!.weightKg, 60);
    expect(active.currentSet!.reps, 8);
    await bloc.close();
  });

  test('validate → rest → next set → next exercise → finish', () async {
    final bloc = build()..add(SessionStarted(programDayId: dayId));
    await next<SessionActive>(bloc);

    // Set 1: rest of 90 s, notification at its end.
    bloc.add(const SetCompleted());
    var resting = await next<SessionResting>(bloc);
    expect(resting.remaining, const Duration(seconds: 90));
    expect(resting.total, const Duration(seconds: 90));
    expect(alerts.scheduled.single.isAtSameMomentAs(resting.endsAt), isTrue);
    expect(haptics.sets, 1);
    expect(resting.position.setIndex, 1);

    // Time passes.
    clock.advance(const Duration(seconds: 30));
    bloc.add(const RestTicked());
    resting = await bloc.stream.firstWhere(
      (s) => s is SessionResting && s.remaining.inSeconds == 60,
    ) as SessionResting;

    // Rest over: back to active, strong vibration.
    clock.advance(const Duration(seconds: 61));
    bloc.add(const RestTicked());
    var active = await next<SessionActive>(bloc);
    expect(haptics.rests, 1);
    expect(active.position, const SessionPosition(0, 1));

    // Set 2: the bench is done, rest before the squat.
    bloc.add(const SetCompleted());
    resting = await next<SessionResting>(bloc);
    expect(resting.position.setIndex, isNull);
    bloc.add(const RestSkipped());
    active = await next<SessionActive>(bloc);
    expect(alerts.cancels, greaterThanOrEqualTo(1));

    // Next exercise.
    bloc.add(const ExerciseSkipped());
    active = await bloc.stream.firstWhere(
      (s) => s is SessionActive && s.position.exerciseIndex == 1,
    ) as SessionActive;
    expect(active.currentSet!.weightKg, 100);

    // Last set: no rest, session complete.
    bloc.add(const SetCompleted());
    active = await bloc.stream.firstWhere(
      (s) => s is SessionActive && s.isComplete,
    ) as SessionActive;

    clock.advance(const Duration(minutes: 40));
    bloc.add(const SessionFinishRequested());
    final finished = await next<SessionFinished>(bloc);
    expect(finished.sessionId, active.details.session.id);
    final history = await sessions.getHistory();
    expect(history.single.exercises, hasLength(2));

    bloc.add(const SessionSummaryClosed());
    await next<SessionIdle>(bloc);
    await bloc.close();
  });

  test('editing a pending set fills the next identical ones', () async {
    final bloc = build()..add(SessionStarted(programDayId: dayId));
    final active = await next<SessionActive>(bloc);
    final first = active.currentExercise!.sets.first;
    bloc.add(
      SetValuesChanged(first.id, const SetValues(reps: 8, weightKg: 70)),
    );
    final updated = await bloc.stream.firstWhere(
      (s) =>
          s is SessionActive &&
          s.currentExercise!.sets.every((set) => set.weightKg == 70),
    ) as SessionActive;
    expect(updated.currentExercise!.sets, hasLength(2));
    await bloc.close();
  });

  test('extend and shorten the rest', () async {
    final bloc = build()..add(SessionStarted(programDayId: dayId));
    await next<SessionActive>(bloc);
    bloc.add(const SetCompleted());
    final first = await next<SessionResting>(bloc);

    bloc.add(const RestExtended(15));
    final longer = await bloc.stream.firstWhere(
      (s) => s is SessionResting && s.endsAt != first.endsAt,
    ) as SessionResting;
    expect(longer.remaining, const Duration(seconds: 105));
    expect(longer.total, const Duration(seconds: 105));
    expect(alerts.scheduled, hasLength(2));

    bloc.add(const RestExtended(-15));
    final shorter = await bloc.stream.firstWhere(
      (s) => s is SessionResting && s.remaining.inSeconds == 90,
    ) as SessionResting;
    expect(shorter.endsAt.isAtSameMomentAs(first.endsAt), isTrue);

    bloc.add(const RestExtended(-120));
    await next<SessionActive>(bloc);
    await bloc.close();
  });

  test('pause stops the clock and the rest', () async {
    final bloc = build()..add(SessionStarted(programDayId: dayId));
    await next<SessionActive>(bloc);
    bloc.add(const SetCompleted());
    final resting = await next<SessionResting>(bloc);

    bloc.add(const SessionPauseRequested());
    await next<SessionPaused>(bloc);
    clock.advance(const Duration(minutes: 10));
    bloc.add(const SessionResumed());
    final resumed = await next<SessionResting>(bloc);
    expect(resumed.remaining, const Duration(seconds: 90));
    expect(
      resumed.endsAt.isAtSameMomentAs(
        resting.endsAt.add(const Duration(minutes: 10)),
      ),
      isTrue,
    );
    expect(resumed.details.session.pausedSeconds, 600);
    await bloc.close();
  });

  test('a rest survives the app being killed', () async {
    final first = build()..add(SessionStarted(programDayId: dayId));
    await next<SessionActive>(first);
    first.add(const SetCompleted());
    await next<SessionResting>(first);
    await first.close();

    // Reopened 40 s later.
    clock.advance(const Duration(seconds: 40));
    final second = build();
    final resting = await next<SessionResting>(second);
    expect(resting.remaining, const Duration(seconds: 50));
    expect(resting.position, const SessionPosition(0, 1));
    await second.close();
  });

  test('a rest that ended while the app was closed is over', () async {
    final first = build()..add(SessionStarted(programDayId: dayId));
    await next<SessionActive>(first);
    first.add(const SetCompleted());
    await next<SessionResting>(first);
    await first.close();

    clock.advance(const Duration(minutes: 5));
    final second = build();
    final active = await next<SessionActive>(second);
    expect(active.position, const SessionPosition(0, 1));
    await second.close();
  });

  test('beating the last session is a record', () async {
    // A finished session: bench 60 kg × 8.
    final bloc = build()..add(SessionStarted(programDayId: dayId));
    await next<SessionActive>(bloc);
    bloc.add(const SessionFinishRequested());
    await next<SessionFinished>(bloc);
    bloc.add(const SessionSummaryClosed());
    await next<SessionIdle>(bloc);
    final past = (await sessions.getHistory()).single;
    expect(past.exercises, isEmpty);

    // Do it for real this time.
    clock.advance(const Duration(days: 2));
    bloc.add(SessionStarted(programDayId: dayId));
    var active = await next<SessionActive>(bloc);
    bloc.add(const SetCompleted());
    await next<SessionResting>(bloc);
    bloc.add(const RestSkipped());
    active = await next<SessionActive>(bloc);
    bloc.add(const SessionFinishRequested());
    await next<SessionFinished>(bloc);
    bloc.add(const SessionSummaryClosed());
    await next<SessionIdle>(bloc);

    // Next time: heavier.
    clock.advance(const Duration(days: 2));
    bloc.add(SessionStarted(programDayId: dayId));
    active = await next<SessionActive>(bloc);
    expect(active.previous[bench]!.first.weightKg, 60);
    final set = active.currentSet!;
    bloc
      ..add(SetValuesChanged(set.id, const SetValues(reps: 8, weightKg: 65)))
      ..add(const SetCompleted());
    final resting = await next<SessionResting>(bloc);
    expect(resting.records[set.id], contains(RecordType.maxWeight));
    expect(resting.records[set.id], contains(RecordType.estimatedOneRepMax));
    await bloc.close();
  });

  test('free session: add an exercise and its sets', () async {
    final bloc = build()..add(const SessionStarted());
    final empty = await next<SessionActive>(bloc);
    expect(empty.details.exercises, isEmpty);
    expect(empty.details.session.name, isNull);

    bloc.add(ExerciseAdded(squat, TrackingType.weightReps));
    final active = await bloc.stream.firstWhere(
      (s) => s is SessionActive && s.details.exercises.isNotEmpty,
    ) as SessionActive;
    expect(active.currentExercise!.sets, hasLength(3));

    bloc.add(const SetAdded());
    final more = await bloc.stream.firstWhere(
      (s) => s is SessionActive && s.currentExercise!.sets.length == 4,
    ) as SessionActive;

    bloc.add(SetRemoved(more.currentExercise!.sets.last.id));
    await bloc.stream.firstWhere(
      (s) => s is SessionActive && s.currentExercise!.sets.length == 3,
    );
    await bloc.close();
  });

  test('discard deletes the session', () async {
    final bloc = build()..add(SessionStarted(programDayId: dayId));
    await next<SessionActive>(bloc);
    bloc.add(const SessionDiscarded());
    await next<SessionIdle>(bloc);
    await settle();
    expect(await sessions.getActive(), isNull);
    expect(await sessions.getHistory(), isEmpty);
    await bloc.close();
  });

  test('selecting an exercise and reordering keep the view', () async {
    final bloc = build()..add(SessionStarted(programDayId: dayId));
    await next<SessionActive>(bloc);
    bloc.add(const ExerciseSelected(1));
    var active = await bloc.stream.firstWhere(
      (s) => s is SessionActive && s.position.exerciseIndex == 1,
    ) as SessionActive;
    expect(active.currentExercise!.exercise.id, squat);

    bloc.add(const ExercisesReordered(1, 0));
    active = await bloc.stream.firstWhere(
      (s) =>
          s is SessionActive && s.details.exercises.first.exercise.id == squat,
    ) as SessionActive;
    // Still on the squat, now first.
    expect(active.position.exerciseIndex, 0);
    expect(active.currentExercise!.exercise.id, squat);

    bloc.add(ExerciseNotesChanged(active.currentExercise!.entry.id, 'Belt'));
    active = await bloc.stream.firstWhere(
      (s) => s is SessionActive && s.currentExercise!.entry.notes == 'Belt',
    ) as SessionActive;

    final set = active.currentSet!;
    bloc.add(SetCompleted(setId: set.id));
    await next<SessionResting>(bloc);
    bloc.add(SetUncompleted(set.id));
    await bloc.stream.firstWhere(
      (s) => s is SessionRunning && s.currentSet?.id == set.id,
    );
    await bloc.close();
  });

  blocTest<SessionBloc, SessionState>(
    'emits idle when nothing is running',
    build: build,
    expect: () => [const SessionIdle()],
  );
}
