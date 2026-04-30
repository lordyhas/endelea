import 'exercise.dart';

class WorkoutSet {
  WorkoutSet({
    this.reps = 0,
    this.weight = 0,
    this.seconds = 0,
    this.done = false,
  });

  int reps;

  /// Weight in kilograms.
  double weight;

  /// Duration in seconds, for timed exercises.
  int seconds;
  bool done;

  double get volume => weight * reps;

  WorkoutSet copy() =>
      WorkoutSet(reps: reps, weight: weight, seconds: seconds, done: done);
}

class WorkoutExercise {
  WorkoutExercise({required this.exercise, List<WorkoutSet>? sets})
    : sets = sets ?? [WorkoutSet()];

  final Exercise exercise;
  final List<WorkoutSet> sets;

  Iterable<WorkoutSet> get completedSets => sets.where((s) => s.done);

  double get volume =>
      completedSets.fold(0, (total, set) => total + set.volume);
}

class Workout {
  Workout({
    required this.id,
    required this.name,
    required this.place,
    required this.startedAt,
    this.finishedAt,
    List<WorkoutExercise>? exercises,
  }) : exercises = exercises ?? [];

  final String id;
  String name;
  final TrainingPlace place;
  final DateTime startedAt;
  DateTime? finishedAt;
  final List<WorkoutExercise> exercises;

  bool get isFinished => finishedAt != null;

  Duration get duration => (finishedAt ?? DateTime.now()).difference(startedAt);

  int get completedSetCount =>
      exercises.fold(0, (total, e) => total + e.completedSets.length);

  double get volume => exercises.fold(0, (total, e) => total + e.volume);
}
