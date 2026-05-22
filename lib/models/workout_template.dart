import 'exercise.dart';
import 'workout.dart';

class TemplateExercise {
  TemplateExercise({required this.exercise, this.sets = 3});

  final Exercise exercise;
  int sets;
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
