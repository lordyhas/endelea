import 'dart:async';
import 'dart:math' as math;

import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/personal_records.dart';
import 'package:endelea/domain/progress/volume.dart';
import 'package:endelea/domain/session/session_planner.dart';
import 'package:endelea/domain/session/session_rules.dart';
import 'package:endelea/features/session/data/session_effects.dart';
import 'package:endelea/features/settings/data/app_settings.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'session_event.dart';
part 'session_state.dart';

/// Runs a synchronous handler as part of the sequential queue.
Future<void> _sync(void Function() handler) async => handler();

/// Processes events one at a time, in order.
EventTransformer<E> _sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);

/// The guided session (PLAN.md §5.1).
///
/// The database is the source of truth: every change is written through
/// [SessionRepository] and the state is rebuilt from the active session
/// stream. The bloc only keeps the viewed exercise, the records beaten and
/// a cache of past sets.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({
    required this.sessions,
    required this.programs,
    required this.clock,
    required this.settings,
    this.alerts = const SilentRestAlerts(),
    this.haptics,
    this.tick = const Duration(seconds: 1),
  }) : super(const SessionLoading()) {
    // One handler for every event: they must run one at a time, in order
    // (transformers apply per event type).
    on<SessionEvent>(
      (event, emit) => switch (event) {
        _ActiveSessionChanged() => _onChanged(event, emit),
        SessionStarted() => _onStarted(event, emit),
        SetCompleted() => _onSetCompleted(event, emit),
        SetUncompleted() => _onSetUncompleted(event, emit),
        SetValuesChanged() => _onValuesChanged(event, emit),
        RestSkipped() => _onRestSkipped(event, emit),
        RestExtended() => _onRestExtended(event, emit),
        RestTicked() => _onRestTicked(event, emit),
        ExerciseSkipped() => _sync(() => _onExerciseSkipped(event, emit)),
        ExerciseSelected() => _sync(() => _onExerciseSelected(event, emit)),
        ExerciseAdded() => _onExerciseAdded(event, emit),
        ExercisesReordered() => _onReordered(event, emit),
        ExerciseNotesChanged() => _onNotesChanged(event, emit),
        SetAdded() => _onSetAdded(event, emit),
        SetRemoved() => _onSetRemoved(event, emit),
        SessionPauseRequested() => _onPause(event, emit),
        SessionResumed() => _onResume(event, emit),
        SessionFinishRequested() => _onFinish(event, emit),
        SessionDiscarded() => _onDiscard(event, emit),
        SessionSummaryClosed() => _sync(() => _onSummaryClosed(event, emit)),
      },
      transformer: _sequential(),
    );

    _subscription = sessions.watchActive().listen(
      (details) => add(_ActiveSessionChanged(details)),
    );
  }

  final SessionRepository sessions;
  final ProgramRepository programs;
  final Clock clock;

  /// Current settings (progression suggestion, default rest).
  final AppSettings Function() settings;
  final RestAlerts alerts;
  final SessionHaptics? haptics;

  /// Rest refresh period.
  final Duration tick;
  late final StreamSubscription<SessionDetails?> _subscription;
  StreamSubscription<void>? _ticker;

  /// Finished sets of past sessions, loaded once per session.
  List<PerformedSet> _history = const [];
  String? _historySessionId;

  /// Viewed exercise, by session exercise id (survives reordering).
  String? _viewedEntryId;
  Map<String, Set<RecordType>> _records = const {};
  DateTime? _scheduledEndsAt;
  Duration? _restTotal;

  SessionDetails? get _details => switch (state) {
    final SessionRunning running => running.details,
    _ => null,
  };

  // -------------------------------------------------------------------------
  // State from the database
  // -------------------------------------------------------------------------

  Future<void> _onChanged(
    _ActiveSessionChanged event,
    Emitter<SessionState> emit,
  ) async {
    final details = event.details;
    if (details == null) {
      await _stopRest();
      _viewedEntryId = null;
      _records = const {};
      if (state is! SessionFinished) emit(const SessionIdle());
      return;
    }
    if (_historySessionId != details.session.id) {
      _history = await sessions.getPerformedSets();
      _historySessionId = details.session.id;
      _records = const {};
      _viewedEntryId = null;
    }
    _emitRunning(details, emit);
  }

  void _emitRunning(SessionDetails details, Emitter<SessionState> emit) {
    final position = _position(details);
    _viewedEntryId = details.exercises.isEmpty
        ? null
        : details.exercises[position.exerciseIndex].entry.id;
    final previous = {
      for (final exercise in details.exercises)
        exercise.exercise.id: previousSets(_history, exercise.exercise.id),
    };
    final session = details.session;
    final now = clock.now();
    final endsAt = session.restEndsAt;

    if (session.pausedAt != null) {
      unawaited(_stopRest());
      emit(
        SessionPaused(
          details: details,
          position: position,
          previous: previous,
          records: _records,
        ),
      );
    } else if (endsAt != null && endsAt.isAfter(now)) {
      final remaining = restRemaining(endsAt, now);
      final total = _restTotal ?? _defaultRest(details, remaining);
      _restTotal = total;
      _startRest(endsAt);
      emit(
        SessionResting(
          details: details,
          position: position,
          previous: previous,
          records: _records,
          endsAt: endsAt,
          remaining: remaining,
          total: total,
        ),
      );
    } else {
      unawaited(_stopRest());
      emit(
        SessionActive(
          details: details,
          position: position,
          previous: previous,
          records: _records,
        ),
      );
    }
  }

  SessionPosition _position(SessionDetails details) {
    final viewed = details.exercises.indexWhere(
      (e) => e.entry.id == _viewedEntryId,
    );
    return viewed < 0 ? initialPosition(details) : positionAt(details, viewed);
  }

  static Duration _defaultRest(SessionDetails details, Duration remaining) {
    final rests = details.exercises.map((e) => e.entry.restSeconds);
    final longest = rests.isEmpty ? 0 : rests.reduce(math.max);
    return Duration(seconds: math.max(longest, remaining.inSeconds));
  }

  void _startRest(DateTime endsAt) {
    if (_scheduledEndsAt != endsAt) {
      _scheduledEndsAt = endsAt;
      unawaited(alerts.schedule(endsAt));
    }
    _ticker ??= Stream<void>.periodic(tick).listen((_) {
      if (!isClosed) add(const RestTicked());
    });
  }

  Future<void> _stopRest() async {
    await _ticker?.cancel();
    _ticker = null;
    _restTotal = null;
    if (_scheduledEndsAt != null) {
      _scheduledEndsAt = null;
      await alerts.cancel();
    }
  }

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    if (state is SessionRunning) return;
    final dayId = event.programDayId;
    final day = dayId == null ? null : await programs.getDay(dayId);
    final history = await sessions.getPerformedSets();
    final plan = day == null
        ? const <PlannedSessionExercise>[]
        : planSession(
            planned: day.exercises,
            history: history,
            progressionSuggestion: settings().progressionSuggestion,
          );
    try {
      await sessions.start(
        plan: plan,
        programDayId: day?.day.id,
        name: day?.day.name,
      );
    } on ActiveSessionExistsException {
      // Already running: the stream shows it.
    }
  }

  Future<void> _onFinish(
    SessionFinishRequested event,
    Emitter<SessionState> emit,
  ) async {
    final details = _details;
    if (details == null) return;
    await _stopRest();
    await sessions.finish(details.session.id);
    emit(SessionFinished(details.session.id));
  }

  Future<void> _onDiscard(
    SessionDiscarded event,
    Emitter<SessionState> emit,
  ) async {
    final details = _details;
    if (details == null) return;
    await _stopRest();
    await sessions.delete(details.session.id);
    emit(const SessionIdle());
  }

  void _onSummaryClosed(
    SessionSummaryClosed event,
    Emitter<SessionState> emit,
  ) {
    if (state is SessionFinished) emit(const SessionIdle());
  }

  Future<void> _onPause(
    SessionPauseRequested event,
    Emitter<SessionState> emit,
  ) async {
    final details = _details;
    if (details == null || details.session.pausedAt != null) return;
    await sessions.pause(details.session.id);
  }

  Future<void> _onResume(
    SessionResumed event,
    Emitter<SessionState> emit,
  ) async {
    final details = _details;
    if (details == null) return;
    await sessions.resume(details.session.id);
  }

  // -------------------------------------------------------------------------
  // Sets
  // -------------------------------------------------------------------------

  Future<void> _onSetCompleted(
    SetCompleted event,
    Emitter<SessionState> emit,
  ) async {
    final running = state;
    if (running is! SessionRunning || running is SessionPaused) return;
    // Re-read: a stepper edit may not have reached the state yet.
    final details =
        await sessions.getDetails(running.details.session.id) ??
        running.details;

    final setId = event.setId ?? running.currentSet?.id;
    if (setId == null) return;
    final exercise = details.exercises
        .where((e) => e.sets.any((s) => s.id == setId))
        .firstOrNull;
    if (exercise == null) return;
    final set = exercise.sets.firstWhere((s) => s.id == setId);
    if (set.completedAt != null) return;

    final values = SetValues(
      reps: set.reps,
      weightKg: set.weightKg,
      durationSeconds: set.durationSeconds,
      distanceMeters: set.distanceMeters,
      isWarmup: set.isWarmup,
    );
    _records = {..._records, setId: _recordsFor(details, exercise, values)}
      ..removeWhere((_, records) => records.isEmpty);

    final restSeconds = exercise.entry.restSeconds;
    final rest = hasPendingSetBesides(details, setId) && restSeconds > 0
        ? Duration(seconds: restSeconds)
        : null;
    _restTotal = rest;
    _viewedEntryId = exercise.entry.id;
    await sessions.completeSet(
      setId,
      values,
      sessionId: details.session.id,
      restEndsAt: rest == null ? null : clock.now().add(rest),
    );
    unawaited(haptics?.setCompleted());
  }

  Set<RecordType> _recordsFor(
    SessionDetails details,
    SessionExerciseDetails exercise,
    SetValues values,
  ) {
    final past = _history.where((s) => s.exerciseId == exercise.exercise.id);
    final done = performedSetsOf(details.session, exercise);
    final volume =
        totalVolume(done) +
        setVolume(
          weightKg: values.weightKg,
          reps: values.reps,
          isWarmup: values.isWarmup,
        );
    return PersonalRecords.fromSets(past).beatenBy(
      set: values,
      trackingType: exercise.trackingType,
      sessionVolumeKg: volume,
    );
  }

  Future<void> _onSetUncompleted(
    SetUncompleted event,
    Emitter<SessionState> emit,
  ) async {
    if (state is! SessionRunning) return;
    _records = {..._records}..remove(event.setId);
    await sessions.uncompleteSet(event.setId);
  }

  Future<void> _onValuesChanged(
    SetValuesChanged event,
    Emitter<SessionState> emit,
  ) async {
    final running = state;
    if (running is! SessionRunning) return;
    final details =
        await sessions.getDetails(running.details.session.id) ??
        running.details;
    await sessions.updateSet(event.setId, event.values);

    // Carry the change to the next pending sets that had the same values,
    // so setting the weight once fills the whole exercise.
    for (final exercise in details.exercises) {
      final index = exercise.sets.indexWhere((s) => s.id == event.setId);
      if (index < 0) continue;
      final edited = exercise.sets[index];
      if (edited.completedAt != null) return;
      final before = _plain(edited);
      for (final next in exercise.sets.skip(index + 1)) {
        if (next.completedAt != null || _plain(next) != before) continue;
        await sessions.updateSet(
          next.id,
          SetValues(
            reps: event.values.reps,
            weightKg: event.values.weightKg,
            durationSeconds: event.values.durationSeconds,
            distanceMeters: event.values.distanceMeters,
            isWarmup: next.isWarmup,
          ),
        );
      }
      return;
    }
  }

  /// Values of a set, warm-up flag aside.
  static SetValues _plain(SetEntry set) => SetValues(
    reps: set.reps,
    weightKg: set.weightKg,
    durationSeconds: set.durationSeconds,
    distanceMeters: set.distanceMeters,
  );

  Future<void> _onSetAdded(SetAdded event, Emitter<SessionState> emit) async {
    final running = state;
    if (running is! SessionRunning) return;
    final exercise = running.currentExercise;
    if (exercise == null) return;
    await sessions.addSet(exercise.entry.id);
  }

  Future<void> _onSetRemoved(
    SetRemoved event,
    Emitter<SessionState> emit,
  ) async {
    if (state is! SessionRunning) return;
    _records = {..._records}..remove(event.setId);
    await sessions.removeSet(event.setId);
  }

  // -------------------------------------------------------------------------
  // Rest
  // -------------------------------------------------------------------------

  Future<void> _onRestSkipped(
    RestSkipped event,
    Emitter<SessionState> emit,
  ) async {
    final running = state;
    if (running is! SessionResting) return;
    await sessions.setRestEndsAt(running.details.session.id, null);
  }

  Future<void> _onRestExtended(
    RestExtended event,
    Emitter<SessionState> emit,
  ) async {
    final running = state;
    if (running is! SessionResting) return;
    final endsAt = running.endsAt.add(Duration(seconds: event.seconds));
    final id = running.details.session.id;
    if (!endsAt.isAfter(clock.now())) {
      await sessions.setRestEndsAt(id, null);
      return;
    }
    if (event.seconds > 0) {
      _restTotal =
          (_restTotal ?? running.total) + Duration(seconds: event.seconds);
    }
    await sessions.setRestEndsAt(id, endsAt);
  }

  Future<void> _onRestTicked(
    RestTicked event,
    Emitter<SessionState> emit,
  ) async {
    final running = state;
    if (running is! SessionResting) return;
    final remaining = restRemaining(running.endsAt, clock.now());
    if (remaining > Duration.zero) {
      emit(
        SessionResting(
          details: running.details,
          position: running.position,
          previous: running.previous,
          records: running.records,
          endsAt: running.endsAt,
          remaining: remaining,
          total: running.total,
        ),
      );
      return;
    }
    // The notification rings at endsAt; in the foreground, also vibrate.
    _scheduledEndsAt = null;
    await _ticker?.cancel();
    _ticker = null;
    unawaited(haptics?.restEnded());
    await sessions.setRestEndsAt(running.details.session.id, null);
  }

  // -------------------------------------------------------------------------
  // Exercises
  // -------------------------------------------------------------------------

  void _onExerciseSelected(ExerciseSelected event, Emitter<SessionState> emit) {
    final details = _details;
    if (details == null || details.exercises.isEmpty) return;
    final index = event.index.clamp(0, details.exercises.length - 1);
    _viewedEntryId = details.exercises[index].entry.id;
    _emitRunning(details, emit);
  }

  void _onExerciseSkipped(ExerciseSkipped event, Emitter<SessionState> emit) {
    final running = state;
    if (running is! SessionRunning) return;
    final details = running.details;
    final next = nextPendingExercise(
      details,
      from: running.position.exerciseIndex,
    );
    final index = next ?? running.position.exerciseIndex + 1;
    if (index >= details.exercises.length) return;
    _viewedEntryId = details.exercises[index].entry.id;
    _emitRunning(details, emit);
  }

  Future<void> _onExerciseAdded(
    ExerciseAdded event,
    Emitter<SessionState> emit,
  ) async {
    final details = _details;
    if (details == null) return;
    _viewedEntryId = await sessions.addExercise(
      details.session.id,
      planAddedExercise(
        exerciseId: event.exerciseId,
        trackingType: event.trackingType,
        history: _history,
        restSeconds: settings().defaultRestSeconds,
      ),
    );
  }

  Future<void> _onReordered(
    ExercisesReordered event,
    Emitter<SessionState> emit,
  ) async {
    final details = _details;
    if (details == null) return;
    await sessions.moveExercise(
      details.session.id,
      event.oldIndex,
      event.newIndex,
    );
  }

  Future<void> _onNotesChanged(
    ExerciseNotesChanged event,
    Emitter<SessionState> emit,
  ) async {
    if (state is! SessionRunning) return;
    await sessions.updateExerciseNotes(event.sessionExerciseId, event.notes);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _ticker?.cancel();
    await super.close();
  }
}
