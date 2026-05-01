import '../models/workout.dart';

/// Aggregated numbers computed from the workout history.
class WorkoutStats {
  WorkoutStats(this.history, {DateTime? now}) : now = now ?? DateTime.now();

  final List<Workout> history;
  final DateTime now;

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Monday of the current week.
  DateTime get weekStart {
    final today = _day(now);
    return today.subtract(Duration(days: today.weekday - 1));
  }

  Iterable<Workout> get thisWeek =>
      history.where((w) => !w.startedAt.isBefore(weekStart));

  int get workoutsThisWeek => thisWeek.length;

  double get volumeThisWeek => thisWeek.fold(0, (total, w) => total + w.volume);

  Duration get timeThisWeek =>
      thisWeek.fold(Duration.zero, (total, w) => total + w.duration);

  /// Number of workouts per weekday of the current week, Monday first.
  List<int> get weekActivity {
    final counts = List.filled(7, 0);
    for (final workout in thisWeek) {
      counts[workout.startedAt.weekday - 1]++;
    }
    return counts;
  }

  /// Consecutive days with at least one workout, ending today or yesterday.
  int get streak {
    final days = history.map((w) => _day(w.startedAt)).toSet();
    var day = _day(now);
    if (!days.contains(day)) {
      day = day.subtract(const Duration(days: 1));
    }
    var count = 0;
    while (days.contains(day)) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }
}
