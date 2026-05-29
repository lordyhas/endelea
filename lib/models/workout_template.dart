import 'exercise.dart';
import 'workout.dart';

class TemplateExercise {
  TemplateExercise({required this.exercise, this.sets = 3});

  final Exercise exercise;
  int sets;

  /// Returns null when the exercise no longer exists.
  static TemplateExercise? fromJson(
    Map<String, dynamic> json,
    ExerciseLookup lookup,
  ) {
    final exercise = lookup(json['exercise'] as String);
    if (exercise == null) return null;
    return TemplateExercise(exercise: exercise, sets: json['sets'] as int);
  }

  Map<String, dynamic> toJson() => {'exercise': exercise.id, 'sets': sets};
}

/// A reusable list of exercises to start a workout from.
class WorkoutTemplate {
  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.place,
    List<TemplateExercise>? exercises,
  }) : exercises = exercises ?? [];

  final String id;
  String name;
  TrainingPlace place;
  final List<TemplateExercise> exercises;

  int get setCount => exercises.fold(0, (total, e) => total + e.sets);

  factory WorkoutTemplate.fromJson(
    Map<String, dynamic> json,
    ExerciseLookup lookup,
  ) => WorkoutTemplate(
    id: json['id'] as String,
    name: json['name'] as String,
    place: TrainingPlace.values.byName(json['place'] as String),
    exercises: [
      for (final entry in json['exercises'] as List)
        ?TemplateExercise.fromJson(entry as Map<String, dynamic>, lookup),
    ],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'place': place.name,
    'exercises': [for (final entry in exercises) entry.toJson()],
  };

  /// Builds a template from the exercises of a finished workout.
  factory WorkoutTemplate.fromWorkout(Workout workout, {required String id}) =>
      WorkoutTemplate(
        id: id,
        name: workout.name,
        place: workout.place,
        exercises: [
          for (final entry in workout.exercises)
            TemplateExercise(
              exercise: entry.exercise,
              sets: entry.sets.isEmpty ? 1 : entry.sets.length,
            ),
        ],
      );
}
