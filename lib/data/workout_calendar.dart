import '../models/workout.dart';

/// Workouts of one month, grouped by day.
class WorkoutCalendar {
  WorkoutCalendar(List<Workout> history, DateTime month)
    : month = DateTime(month.year, month.month) {
    for (final workout in history) {
      final date = workout.startedAt;
      if (date.year != this.month.year || date.month != this.month.month) {
        continue;
      }
      (_byDay[date.day] ??= []).add(workout);
    }
    for (final workouts in _byDay.values) {
      workouts.sort((a, b) => a.startedAt.compareTo(b.startedAt));
    }
  }

  /// First day of the month.
  final DateTime month;

  final Map<int, List<Workout>> _byDay = {};

  int get daysInMonth => DateTime(month.year, month.month + 1, 0).day;

  /// Number of empty cells before the 1st in a week starting on Monday.
  int get leadingBlanks => month.weekday - 1;

  /// Workouts started on [day] of the month, oldest first.
  List<Workout> workoutsOn(int day) => _byDay[day] ?? const [];

  int get activeDays => _byDay.length;

  int get workoutCount =>
      _byDay.values.fold(0, (total, workouts) => total + workouts.length);

  WorkoutCalendar previous(List<Workout> history) =>
      WorkoutCalendar(history, DateTime(month.year, month.month - 1));

  WorkoutCalendar next(List<Workout> history) =>
      WorkoutCalendar(history, DateTime(month.year, month.month + 1));
}
