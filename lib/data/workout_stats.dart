import '../models/exercise.dart';
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

  /// Working sets done this week for each muscle group, most worked first.
  Map<MuscleGroup, int> get setsPerMuscleThisWeek {
    final counts = <MuscleGroup, int>{};
    for (final workout in thisWeek) {
      for (final entry in workout.exercises) {
        final sets = entry.workingSets.length;
        if (sets == 0) continue;
        counts.update(
          entry.exercise.muscleGroup,
          (count) => count + sets,
          ifAbsent: () => sets,
        );
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted);
  }

  /// Most consecutive days with a workout, at any time.
  int get longestStreak {
    final days = history.map((w) => _day(w.startedAt)).toSet().toList()..sort();
    var best = 0;
    var current = 0;
    DateTime? previous;
    for (final day in days) {
      final next = previous == null
          ? null
          : DateTime(previous.year, previous.month, previous.day + 1);
      current = day == next ? current + 1 : 1;
      if (current > best) best = current;
      previous = day;
    }
    return best;
  }

  int get totalWorkouts => history.length;

  double get totalVolume => history.fold(0, (total, w) => total + w.volume);

  Duration get totalTime =>
      history.fold(Duration.zero, (total, w) => total + w.duration);

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
