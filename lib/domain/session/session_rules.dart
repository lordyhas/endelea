import 'package:endelea/data/database.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:equatable/equatable.dart';

/// Where the user is in a session: an exercise and, unless it is done, its
/// current set.
class SessionPosition extends Equatable {
  const SessionPosition(this.exerciseIndex, this.setIndex);

  final int exerciseIndex;

  /// Index in the exercise's set list, null when every set is done.
  final int? setIndex;

  @override
  List<Object?> get props => [exerciseIndex, setIndex];
}

/// Index of the first set not done yet, or null.
int? pendingSetIndex(SessionExerciseDetails exercise) {
  final index = exercise.sets.indexWhere((s) => s.completedAt == null);
  return index < 0 ? null : index;
}

/// Index of the next exercise with a set left, searching after [from] and
/// then from the start. Null when everything is done.
int? nextPendingExercise(SessionDetails session, {required int from}) {
  final count = session.exercises.length;
  for (var step = 1; step <= count; step++) {
    final index = (from + step) % count;
    if (pendingSetIndex(session.exercises[index]) != null) return index;
  }
  return null;
}

/// Position on exercise [exerciseIndex] (clamped to the list).
SessionPosition positionAt(SessionDetails session, int exerciseIndex) {
  if (session.exercises.isEmpty) return const SessionPosition(0, null);
  final index = exerciseIndex.clamp(0, session.exercises.length - 1);
  return SessionPosition(index, pendingSetIndex(session.exercises[index]));
}

/// The first exercise with a set left, or the first exercise.
SessionPosition initialPosition(SessionDetails session) {
  final first = session.exercises.indexWhere((e) => pendingSetIndex(e) != null);
  return positionAt(session, first < 0 ? 0 : first);
}

bool isSessionComplete(SessionDetails session) =>
    session.exercises.every((e) => pendingSetIndex(e) == null);

/// True if a set other than [setId] is left anywhere in the session.
bool hasPendingSetBesides(SessionDetails session, String setId) => session
    .exercises
    .any((e) => e.sets.any((s) => s.completedAt == null && s.id != setId));

/// Session duration at [now], pauses excluded.
Duration sessionElapsed(WorkoutSession session, DateTime now) {
  final end = session.endedAt ?? session.pausedAt ?? now;
  final total = end.difference(session.startedAt).inSeconds;
  final seconds = total - session.pausedSeconds;
  return Duration(seconds: seconds < 0 ? 0 : seconds);
}

/// Rest left at [now], never negative.
Duration restRemaining(DateTime endsAt, DateTime now) {
  final left = endsAt.difference(now);
  return left.isNegative ? Duration.zero : left;
}

/// Completed working sets of [exercise] as [PerformedSet]s.
List<PerformedSet> performedSetsOf(
  WorkoutSession session,
  SessionExerciseDetails exercise,
) {
  return [
    for (final set in exercise.sets)
      if (set.completedAt != null)
        PerformedSet(
          setId: set.id,
          sessionId: session.id,
          sessionStartedAt: session.startedAt,
          exerciseId: exercise.exercise.id,
          setIndex: set.setIndex,
          isWarmup: set.isWarmup,
          reps: set.reps,
          weightKg: set.weightKg,
          durationSeconds: set.durationSeconds,
          distanceMeters: set.distanceMeters,
        ),
  ];
}
