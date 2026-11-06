part of 'session_bloc.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

/// Looking for a session in progress (app start).
final class SessionLoading extends SessionState {
  const SessionLoading();
}

/// No session in progress.
final class SessionIdle extends SessionState {
  const SessionIdle();
}

/// A session in progress, whatever its mode.
sealed class SessionRunning extends SessionState {
  const SessionRunning({
    required this.details,
    required this.position,
    required this.previous,
    required this.records,
  });

  final SessionDetails details;

  /// Viewed exercise and its current set.
  final SessionPosition position;

  /// "Previous" sets per exercise id.
  final Map<String, List<PerformedSet>> previous;

  /// Records beaten in this session, per set id.
  final Map<String, Set<RecordType>> records;

  SessionExerciseDetails? get currentExercise => details.exercises.isEmpty
      ? null
      : details.exercises[position.exerciseIndex];

  SetEntry? get currentSet {
    final setIndex = position.setIndex;
    final exercise = currentExercise;
    return exercise == null || setIndex == null
        ? null
        : exercise.sets[setIndex];
  }

  bool get isComplete => isSessionComplete(details);

  @override
  List<Object?> get props => [details, position, previous, records];
}

final class SessionActive extends SessionRunning {
  const SessionActive({
    required super.details,
    required super.position,
    required super.previous,
    required super.records,
  });
}

/// Resting between sets. The rest is stored as its end ([endsAt]).
final class SessionResting extends SessionRunning {
  const SessionResting({
    required super.details,
    required super.position,
    required super.previous,
    required super.records,
    required this.endsAt,
    required this.remaining,
    required this.total,
  });

  final DateTime endsAt;
  final Duration remaining;

  /// Full length of the rest, for the progress bar.
  final Duration total;

  @override
  List<Object?> get props => [...super.props, endsAt, remaining, total];
}

/// Paused: the session clock and the rest are stopped.
final class SessionPaused extends SessionRunning {
  const SessionPaused({
    required super.details,
    required super.position,
    required super.previous,
    required super.records,
  });
}

/// Just finished: show its summary.
final class SessionFinished extends SessionState {
  const SessionFinished(this.sessionId);

  final String sessionId;

  @override
  List<Object?> get props => [sessionId];
}
