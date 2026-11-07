part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

/// Starts a session from a program day, or a free session.
final class SessionStarted extends SessionEvent {
  const SessionStarted({this.programDayId});

  final String? programDayId;

  @override
  List<Object?> get props => [programDayId];
}

/// Validates a set: the current one by default.
final class SetCompleted extends SessionEvent {
  const SetCompleted({this.setId});

  final String? setId;

  @override
  List<Object?> get props => [setId];
}

/// Marks a validated set as not done again.
final class SetUncompleted extends SessionEvent {
  const SetUncompleted(this.setId);

  final String setId;

  @override
  List<Object?> get props => [setId];
}

/// Edits the values of a set (steppers).
final class SetValuesChanged extends SessionEvent {
  const SetValuesChanged(this.setId, this.values);

  final String setId;
  final SetValues values;

  @override
  List<Object?> get props => [setId, values];
}

final class RestSkipped extends SessionEvent {
  const RestSkipped();
}

/// Adds (or removes, if negative) time to the current rest.
final class RestExtended extends SessionEvent {
  const RestExtended(this.seconds);

  final int seconds;

  @override
  List<Object?> get props => [seconds];
}

/// Internal: one second passed during a rest.
final class RestTicked extends SessionEvent {
  const RestTicked();
}

/// Moves to the next exercise with a set left.
final class ExerciseSkipped extends SessionEvent {
  const ExerciseSkipped();
}

final class ExerciseSelected extends SessionEvent {
  const ExerciseSelected(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class ExerciseAdded extends SessionEvent {
  const ExerciseAdded(this.exerciseId, this.trackingType);

  final String exerciseId;
  final TrackingType trackingType;

  @override
  List<Object?> get props => [exerciseId, trackingType];
}

/// [newIndex] is the final position of the exercise.
final class ExercisesReordered extends SessionEvent {
  const ExercisesReordered(this.oldIndex, this.newIndex);

  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

final class ExerciseNotesChanged extends SessionEvent {
  const ExerciseNotesChanged(this.sessionExerciseId, this.notes);

  final String sessionExerciseId;
  final String? notes;

  @override
  List<Object?> get props => [sessionExerciseId, notes];
}

/// Adds a set to the viewed exercise.
final class SetAdded extends SessionEvent {
  const SetAdded();
}

final class SetRemoved extends SessionEvent {
  const SetRemoved(this.setId);

  final String setId;

  @override
  List<Object?> get props => [setId];
}

final class SessionPauseRequested extends SessionEvent {
  const SessionPauseRequested();
}

final class SessionResumed extends SessionEvent {
  const SessionResumed();
}

final class SessionFinishRequested extends SessionEvent {
  const SessionFinishRequested();
}

/// Deletes the session in progress.
final class SessionDiscarded extends SessionEvent {
  const SessionDiscarded();
}

/// The summary of a finished session was closed.
final class SessionSummaryClosed extends SessionEvent {
  const SessionSummaryClosed();
}

/// Internal: the session in the database changed.
final class _ActiveSessionChanged extends SessionEvent {
  const _ActiveSessionChanged(this.details);

  final SessionDetails? details;

  @override
  List<Object?> get props => [details];
}
