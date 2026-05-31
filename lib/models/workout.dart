import 'exercise.dart';

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

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
    reps: json['reps'] as int? ?? 0,
    weight: (json['weight'] as num? ?? 0).toDouble(),
    seconds: json['seconds'] as int? ?? 0,
    done: json['done'] as bool? ?? false,
    warmUp: json['warmUp'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'reps': reps,
    'weight': weight,
    'seconds': seconds,
    'done': done,
    if (warmUp) 'warmUp': true,
  };
}

class WorkoutExercise {
  WorkoutExercise({required this.exercise, List<WorkoutSet>? sets})
    : sets = sets ?? [WorkoutSet()];

  final Exercise exercise;
  final List<WorkoutSet> sets;

  Iterable<WorkoutSet> get completedSets => sets.where((s) => s.done);

  /// Completed sets without the warm-ups.
  Iterable<WorkoutSet> get workingSets => completedSets.where((s) => !s.warmUp);

  double get volume => workingSets.fold(0, (total, set) => total + set.volume);

  /// Returns null when the exercise no longer exists.
  static WorkoutExercise? fromJson(
    Map<String, dynamic> json,
    ExerciseLookup lookup,
  ) {
    final exercise = lookup(json['exercise'] as String);
    if (exercise == null) return null;
    return WorkoutExercise(
      exercise: exercise,
      sets: [
        for (final set in json['sets'] as List)
          WorkoutSet.fromJson(set as Map<String, dynamic>),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'exercise': exercise.id,
    'sets': [for (final set in sets) set.toJson()],
  };
}

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

  factory Workout.fromJson(Map<String, dynamic> json, ExerciseLookup lookup) {
    final finishedAt = json['finishedAt'] as String?;
    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      place: TrainingPlace.values.byName(json['place'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      finishedAt: finishedAt == null ? null : DateTime.parse(finishedAt),
      notes: json['notes'] as String? ?? '',
      exercises: [
        for (final entry in json['exercises'] as List)
          ?WorkoutExercise.fromJson(entry as Map<String, dynamic>, lookup),
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'place': place.name,
    'startedAt': startedAt.toIso8601String(),
    'finishedAt': finishedAt?.toIso8601String(),
    'notes': notes,
    'exercises': [for (final entry in exercises) entry.toJson()],
  };
}
