import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_template.dart';
import 'exercise_catalog.dart';

/// A few past workouts so the prototype does not start empty.
List<Workout> demoHistory({DateTime? now}) {
  final today = now ?? DateTime.now();
  DateTime daysAgo(int days, int hour) =>
      DateTime(today.year, today.month, today.day - days, hour);

  WorkoutExercise entry(String id, List<WorkoutSet> sets) =>
      WorkoutExercise(exercise: exerciseById(id)!, sets: sets);

  List<WorkoutSet> sets(
    int count, {
    double kg = 0,
    int reps = 0,
    int sec = 0,
  }) => List.generate(
    count,
    (_) => WorkoutSet(weight: kg, reps: reps, seconds: sec, done: true),
  );

  Workout workout(
    String name,
    TrainingPlace place,
    DateTime start,
    int minutes,
    List<WorkoutExercise> exercises,
  ) => Workout(
    id: 'demo-${start.millisecondsSinceEpoch}',
    name: name,
    place: place,
    startedAt: start,
    finishedAt: start.add(Duration(minutes: minutes)),
    exercises: exercises,
  );

  return [
    workout('Push day', TrainingPlace.gym, daysAgo(1, 18), 62, [
      entry('bench-press', sets(4, kg: 60, reps: 8)),
      entry('overhead-press', sets(3, kg: 35, reps: 8)),
      entry('db-curl', sets(3, kg: 12, reps: 12)),
    ]),
    workout('Home circuit', TrainingPlace.home, daysAgo(2, 7), 28, [
      entry('push-up', sets(3, reps: 20)),
      entry('air-squat', sets(3, reps: 25)),
      entry('plank', sets(3, sec: 60)),
      entry('burpee', sets(2, reps: 12)),
    ]),
    workout('Leg day', TrainingPlace.gym, daysAgo(4, 18), 55, [
      entry('back-squat', sets(5, kg: 80, reps: 5)),
      entry('leg-press', sets(3, kg: 140, reps: 10)),
      entry('lunge', sets(3, reps: 12)),
    ]),
    workout('Push day', TrainingPlace.gym, daysAgo(8, 18), 60, [
      entry('bench-press', sets(4, kg: 57.5, reps: 8)),
      entry('overhead-press', sets(3, kg: 32.5, reps: 8)),
      entry('db-curl', sets(3, kg: 12, reps: 10)),
    ]),
    workout('Home circuit', TrainingPlace.home, daysAgo(9, 7), 25, [
      entry('push-up', sets(3, reps: 16)),
      entry('air-squat', sets(3, reps: 20)),
      entry('plank', sets(3, sec: 45)),
    ]),
    workout('Leg day', TrainingPlace.gym, daysAgo(11, 18), 52, [
      entry('back-squat', sets(5, kg: 75, reps: 5)),
      entry('leg-press', sets(3, kg: 130, reps: 10)),
    ]),
    workout('Push day', TrainingPlace.gym, daysAgo(15, 18), 58, [
      entry('bench-press', sets(4, kg: 55, reps: 8)),
      entry('overhead-press', sets(3, kg: 30, reps: 8)),
    ]),
    workout('Leg day', TrainingPlace.gym, daysAgo(18, 18), 50, [
      entry('back-squat', sets(5, kg: 70, reps: 5)),
      entry('leg-press', sets(3, kg: 120, reps: 10)),
    ]),
    workout('Pull day', TrainingPlace.gym, daysAgo(6, 19), 58, [
      entry('deadlift', sets(3, kg: 100, reps: 5)),
      entry('lat-pulldown', sets(3, kg: 50, reps: 10)),
      entry('seated-row', sets(3, kg: 45, reps: 10)),
    ]),
  ];
}

/// Starter templates for the prototype.
List<WorkoutTemplate> demoTemplates() {
  TemplateExercise entry(String id, int sets) =>
      TemplateExercise(exercise: exerciseById(id)!, sets: sets);

  return [
    WorkoutTemplate(
      id: 'demo-full-body-gym',
      name: 'Full body',
      place: TrainingPlace.gym,
      exercises: [
        entry('back-squat', 4),
        entry('bench-press', 4),
        entry('seated-row', 3),
        entry('overhead-press', 3),
      ],
    ),
    WorkoutTemplate(
      id: 'demo-home-20',
      name: '20 min at home',
      place: TrainingPlace.home,
      exercises: [
        entry('jumping-jacks', 2),
        entry('push-up', 3),
        entry('air-squat', 3),
        entry('plank', 3),
      ],
    ),
  ];
}
