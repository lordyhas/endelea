import 'package:endelea/data/database.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:equatable/equatable.dart';

/// An exercise of a session with its catalog entry and its sets.
class SessionExerciseDetails extends Equatable {
  const SessionExerciseDetails({
    required this.entry,
    required this.exercise,
    required this.sets,
  });

  final SessionExercise entry;
  final Exercise exercise;

  /// Ordered by `setIndex`.
  final List<SetEntry> sets;

  TrackingType get trackingType => TrackingType.fromKey(exercise.trackingType);

  bool get isDone =>
      sets.isNotEmpty && sets.every((s) => s.completedAt != null);

  @override
  List<Object?> get props => [entry, exercise, sets];
}

/// A session with all its exercises and sets.
class SessionDetails extends Equatable {
  const SessionDetails({required this.session, required this.exercises});

  final WorkoutSession session;

  /// Ordered by `orderIndex`.
  final List<SessionExerciseDetails> exercises;

  bool get isActive => session.endedAt == null;

  @override
  List<Object?> get props => [session, exercises];
}

/// A completed set flattened with its session and exercise, the input of
/// every progress calculation.
class PerformedSet extends Equatable {
  const PerformedSet({
    required this.setId,
    required this.sessionId,
    required this.sessionStartedAt,
    required this.exerciseId,
    required this.setIndex,
    required this.isWarmup,
    this.reps,
    this.weightKg,
    this.durationSeconds,
    this.distanceMeters,
  });

  final String setId;
  final String sessionId;
  final DateTime sessionStartedAt;
  final String exerciseId;
  final int setIndex;
  final bool isWarmup;
  final int? reps;
  final double? weightKg;
  final int? durationSeconds;
  final double? distanceMeters;

  @override
  List<Object?> get props => [
    setId,
    sessionId,
    sessionStartedAt,
    exerciseId,
    setIndex,
    isWarmup,
    reps,
    weightKg,
    durationSeconds,
    distanceMeters,
  ];
}

/// Values of a set as entered by the user.
class SetValues extends Equatable {
  const SetValues({
    this.reps,
    this.weightKg,
    this.durationSeconds,
    this.distanceMeters,
    this.isWarmup = false,
  });

  final int? reps;
  final double? weightKg;
  final int? durationSeconds;
  final double? distanceMeters;
  final bool isWarmup;

  SetValues copyWith({
    int? reps,
    double? weightKg,
    int? durationSeconds,
    double? distanceMeters,
    bool? isWarmup,
  }) {
    return SetValues(
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      isWarmup: isWarmup ?? this.isWarmup,
    );
  }

  @override
  List<Object?> get props => [
    reps,
    weightKg,
    durationSeconds,
    distanceMeters,
    isWarmup,
  ];
}

/// One exercise of a session about to start, with its pre-filled sets.
class PlannedSessionExercise extends Equatable {
  const PlannedSessionExercise({
    required this.exerciseId,
    required this.sets,
    required this.restSeconds,
    this.programExerciseId,
    this.targetRepsMin,
    this.targetRepsMax,
    this.notes,
  });

  final String exerciseId;
  final String? programExerciseId;
  final List<SetValues> sets;
  final int? targetRepsMin;
  final int? targetRepsMax;
  final int restSeconds;
  final String? notes;

  @override
  List<Object?> get props => [
    exerciseId,
    programExerciseId,
    sets,
    targetRepsMin,
    targetRepsMax,
    restSeconds,
    notes,
  ];
}
