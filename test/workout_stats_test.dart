import 'package:endelea/data/exercise_catalog.dart';
import 'package:endelea/data/workout_stats.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/workout.dart';
import 'package:flutter_test/flutter_test.dart';

Workout _workoutOn(DateTime day) => Workout(
  id: day.toIso8601String(),
  name: 'w',
  place: TrainingPlace.home,
  startedAt: day,
  finishedAt: day.add(const Duration(minutes: 30)),
);

void main() {
  // Thursday.
  final now = DateTime(2026, 4, 30, 12);

  test('streak counts consecutive days ending today', () {
    final stats = WorkoutStats([
      _workoutOn(DateTime(2026, 4, 30, 8)),
      _workoutOn(DateTime(2026, 4, 29, 8)),
      _workoutOn(DateTime(2026, 4, 28, 8)),
      _workoutOn(DateTime(2026, 4, 26, 8)),
    ], now: now);

    expect(stats.streak, 3);
  });

  test('streak still counts when the last workout was yesterday', () {
    final stats = WorkoutStats([
      _workoutOn(DateTime(2026, 4, 29, 8)),
      _workoutOn(DateTime(2026, 4, 28, 8)),
    ], now: now);

    expect(stats.streak, 2);
  });

  test('streak is zero after a missed day', () {
    final stats = WorkoutStats([_workoutOn(DateTime(2026, 4, 27))], now: now);

    expect(stats.streak, 0);
  });

  test('weekly numbers only include workouts since Monday', () {
    final stats = WorkoutStats([
      _workoutOn(DateTime(2026, 4, 27, 8)),
      _workoutOn(DateTime(2026, 4, 30, 8)),
      _workoutOn(DateTime(2026, 4, 26, 8)),
    ], now: now);

    expect(stats.weekStart, DateTime(2026, 4, 27));
    expect(stats.workoutsThisWeek, 2);
    expect(stats.weekActivity, [1, 0, 0, 1, 0, 0, 0]);
    expect(stats.timeThisWeek, const Duration(hours: 1));
  });

  test('totals cover the whole history', () {
    final stats = WorkoutStats([
      _workoutOn(DateTime(2026, 4, 30, 8)),
      _workoutOn(DateTime(2026, 3, 2, 8)),
      _workoutOn(DateTime(2025, 12, 24, 8)),
    ], now: now);

    expect(stats.totalWorkouts, 3);
    expect(stats.totalTime, const Duration(minutes: 90));
    expect(stats.totalVolume, 0);
    expect(stats.workoutsThisWeek, 1);
  });

  test('counts working sets per muscle group this week', () {
    WorkoutExercise entry(String id, int sets, {int warmUps = 0}) =>
        WorkoutExercise(
          exercise: exerciseById(id)!,
          sets: [
            for (var i = 0; i < warmUps; i++)
              WorkoutSet(done: true, warmUp: true),
            for (var i = 0; i < sets; i++) WorkoutSet(done: true),
          ],
        );
    final monday = _workoutOn(DateTime(2026, 4, 27, 8))
      ..exercises.addAll([entry('bench-press', 3, warmUps: 2)]);
    final wednesday = _workoutOn(DateTime(2026, 4, 29, 8))
      ..exercises.addAll([entry('back-squat', 5), entry('bench-press', 1)]);
    final lastWeek = _workoutOn(DateTime(2026, 4, 22, 8))
      ..exercises.addAll([entry('back-squat', 10)]);

    final stats = WorkoutStats([monday, wednesday, lastWeek], now: now);

    expect(stats.setsPerMuscleThisWeek, {
      MuscleGroup.legs: 5,
      MuscleGroup.chest: 4,
    });
    expect(stats.setsPerMuscleThisWeek.keys.first, MuscleGroup.legs);
  });
}
