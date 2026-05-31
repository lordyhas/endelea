import 'package:endelea/data/exercise_catalog.dart';
import 'package:endelea/data/exercise_progress.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/workout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final bench = exerciseById('bench-press')!;
  final workout = Workout(
    id: 'w1',
    name: 'Push',
    place: TrainingPlace.gym,
    startedAt: DateTime(2026, 5, 31, 8),
    finishedAt: DateTime(2026, 5, 31, 9),
    exercises: [
      WorkoutExercise(
        exercise: bench,
        sets: [
          WorkoutSet(weight: 100, reps: 2, done: true, warmUp: true),
          WorkoutSet(weight: 60, reps: 8, done: true),
        ],
      ),
    ],
  );

  test('warm-up sets do not count in the volume', () {
    expect(workout.exercises.single.completedSets, hasLength(2));
    expect(workout.exercises.single.workingSets, hasLength(1));
    expect(workout.volume, 480);
  });

  test('warm-up sets do not count as records', () {
    expect(ExerciseProgress(bench, [workout]).heaviestWeight, 60);
  });

  test('warm-up flag survives json and copies', () {
    final set = workout.exercises.single.sets.first;

    expect(WorkoutSet.fromJson(set.toJson()).warmUp, isTrue);
    expect(set.copy().warmUp, isTrue);
    expect(
      workout.exercises.single.sets.last.toJson(),
      isNot(contains('warmUp')),
    );
  });
}
