import 'exercise.dart';

/// One set of an exercise: weight and reps, or a duration.
class WorkoutSet {
  WorkoutSet({
    this.reps = 0,
    this.weight = 0,
    this.seconds = 0,
    this.done = false,
    this.warmUp = false,
  });

  int reps;

  /// Weight in kilograms.
  double weight;

  /// Duration in seconds, for timed exercises.
  int seconds;
  bool done;

  /// Warm-up sets are logged but do not count in volume and records.
  bool warmUp;

  double get volume => weight * reps;

  WorkoutSet copy() => WorkoutSet(
    reps: reps,
    weight: weight,
    seconds: seconds,
    done: done,
    warmUp: warmUp,
  );
}

/// An exercise done in a workout with its sets.
class WorkoutExercise {
  WorkoutExercise({required this.exercise, List<WorkoutSet>? sets})
    : sets = sets ?? [WorkoutSet()];

  final Exercise exercise;
  final List<WorkoutSet> sets;

  Iterable<WorkoutSet> get completedSets => sets.where((s) => s.done);

  /// Completed sets without the warm-ups.
  Iterable<WorkoutSet> get workingSets => completedSets.where((s) => !s.warmUp);

  double get volume => workingSets.fold(0, (total, set) => total + set.volume);
}

/// A training session, in progress or finished.
class Workout {
  Workout({
    required this.id,
    required this.name,
    required this.place,
    required this.startedAt,
    this.finishedAt,
    this.notes = '',
    List<WorkoutExercise>? exercises,
  }) : exercises = exercises ?? [];

  final String id;
  String name;
  final TrainingPlace place;
  final DateTime startedAt;
  DateTime? finishedAt;
  String notes;
  final List<WorkoutExercise> exercises;

  bool get isFinished => finishedAt != null;

  Duration get duration => (finishedAt ?? DateTime.now()).difference(startedAt);

  int get completedSetCount =>
      exercises.fold(0, (total, e) => total + e.completedSets.length);

  double get volume => exercises.fold(0, (total, e) => total + e.volume);
}
