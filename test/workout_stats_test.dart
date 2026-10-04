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
}
