import 'package:endelea/data/exercise_catalog.dart';
import 'package:endelea/data/exercise_progress.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/workout.dart';
import 'package:flutter_test/flutter_test.dart';

Workout _workout(DateTime day, String exerciseId, List<WorkoutSet> sets) =>
    Workout(
      id: day.toIso8601String(),
      name: 'w',
      place: TrainingPlace.gym,
      startedAt: day,
      finishedAt: day.add(const Duration(hours: 1)),
      exercises: [
        WorkoutExercise(exercise: exerciseById(exerciseId)!, sets: sets),
      ],
    );

WorkoutSet _set(double kg, int reps, {bool done = true}) =>
    WorkoutSet(weight: kg, reps: reps, done: done);

void main() {
  test('estimatedOneRepMax uses the Epley formula', () {
    expect(estimatedOneRepMax(100, 1), 100);
    expect(estimatedOneRepMax(60, 10), 80);
    expect(estimatedOneRepMax(0, 10), 0);
  });

  test('builds one point per workout, oldest first', () {
    final bench = exerciseById('bench-press')!;
    final progress = ExerciseProgress(bench, [
      _workout(DateTime(2026, 5, 20), 'bench-press', [
        _set(60, 8),
        _set(65, 5),
      ]),
      _workout(DateTime(2026, 5, 13), 'bench-press', [_set(55, 10)]),
      _workout(DateTime(2026, 5, 15), 'back-squat', [_set(80, 5)]),
    ]);

    expect(progress.points, hasLength(2));
    expect(progress.points.first.date, DateTime(2026, 5, 13));
    expect(progress.last!.bestWeight, 65);
    expect(progress.last!.heaviestSetReps, 5);
    expect(progress.last!.bestReps, 8);
    expect(progress.last!.volume, 60 * 8 + 65 * 5);
    expect(progress.heaviestWeight, 65);
    expect(progress.mostReps, 10);
    expect(progress.bestOneRepMax, closeTo(76, 0.01));
  });

  test('ignores sets that were not completed', () {
    final bench = exerciseById('bench-press')!;
    final progress = ExerciseProgress(bench, [
      _workout(DateTime(2026, 5, 20), 'bench-press', [
        _set(100, 5, done: false),
        _set(60, 5),
      ]),
    ]);

    expect(progress.heaviestWeight, 60);
  });

  test('is empty when the exercise was never done', () {
    final progress = ExerciseProgress(exerciseById('plank')!, []);

    expect(progress.isEmpty, isTrue);
    expect(progress.last, isNull);
    expect(progress.heaviestWeight, 0);
  });
}
