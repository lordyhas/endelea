import 'package:endelea/data/exercise_catalog.dart';
import 'package:endelea/data/template_store.dart';
import 'package:endelea/data/workout_store.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/workout.dart';
import 'package:endelea/models/workout_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TemplateExercise entry(String id, int sets) =>
      TemplateExercise(exercise: exerciseById(id)!, sets: sets);

  test('creates and removes templates', () {
    final store = TemplateStore();
    final template = store.create(
      name: 'Legs',
      place: TrainingPlace.gym,
      exercises: [entry('back-squat', 5)],
    );

    expect(store.templates, [template]);
    expect(template.setCount, 5);

    store.remove(template);
    expect(store.templates, isEmpty);
  });

  test('saves a finished workout as a template', () {
    final store = TemplateStore();
    final workout = Workout(
      id: 'w',
      name: 'Push day',
      place: TrainingPlace.gym,
      startedAt: DateTime(2026, 5, 22),
      exercises: [
        WorkoutExercise(
          exercise: exerciseById('bench-press')!,
          sets: [WorkoutSet(done: true), WorkoutSet(done: true)],
        ),
      ],
    );

    final template = store.saveWorkout(workout);

    expect(template.name, 'Push day');
    expect(template.exercises.single.exercise.id, 'bench-press');
    expect(template.exercises.single.sets, 2);
  });

  test('starts a workout prefilled from a template', () {
    final workouts = WorkoutStore();
    final template = WorkoutTemplate(
      id: 't',
      name: 'Home',
      place: TrainingPlace.home,
      exercises: [entry('push-up', 3), entry('plank', 2)],
    );

    final workout = workouts.startFromTemplate(template);

    expect(workouts.active, workout);
    expect(workout.name, 'Home');
    expect(workout.place, TrainingPlace.home);
    expect(workout.exercises.map((e) => e.sets.length), [3, 2]);
    expect(workout.completedSetCount, 0);
  });
}
