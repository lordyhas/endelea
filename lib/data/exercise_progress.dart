import '../models/exercise.dart';
import '../models/workout.dart';

/// Estimated one-rep max with the Epley formula.
double estimatedOneRepMax(double weight, int reps) {
  if (weight <= 0 || reps <= 0) return 0;
  if (reps == 1) return weight;
  return weight * (1 + reps / 30);
}

/// Best numbers of one exercise in one workout.
class ProgressPoint {
  const ProgressPoint({
    required this.date,
    required this.bestWeight,
    required this.bestReps,
    required this.bestSeconds,
    required this.oneRepMax,
    required this.volume,
  });

  final DateTime date;
  final double bestWeight;
  final int bestReps;
  final int bestSeconds;
  final double oneRepMax;
  final double volume;
}

/// History of one exercise across finished workouts.
class ExerciseProgress {
  ExerciseProgress(this.exercise, List<Workout> history)
    : points = _points(exercise, history);

  final Exercise exercise;

  /// One point per workout containing the exercise, oldest first.
  final List<ProgressPoint> points;

  static List<ProgressPoint> _points(Exercise exercise, List<Workout> history) {
    final points = <ProgressPoint>[];
    for (final workout in history) {
      final sets = workout.exercises
          .where((e) => e.exercise.id == exercise.id)
          .expand((e) => e.completedSets)
          .toList();
      if (sets.isEmpty) continue;
      points.add(
        ProgressPoint(
          date: workout.startedAt,
          bestWeight: sets.map((s) => s.weight).reduce(_max),
          bestReps: sets.map((s) => s.reps).reduce(_maxInt),
          bestSeconds: sets.map((s) => s.seconds).reduce(_maxInt),
          oneRepMax: sets
              .map((s) => estimatedOneRepMax(s.weight, s.reps))
              .reduce(_max),
          volume: sets.fold(0, (total, s) => total + s.volume),
        ),
      );
    }
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  static double _max(double a, double b) => a > b ? a : b;
  static int _maxInt(int a, int b) => a > b ? a : b;

  bool get isEmpty => points.isEmpty;

  double get heaviestWeight =>
      points.isEmpty ? 0 : points.map((p) => p.bestWeight).reduce(_max);

  double get bestOneRepMax =>
      points.isEmpty ? 0 : points.map((p) => p.oneRepMax).reduce(_max);

  int get mostReps =>
      points.isEmpty ? 0 : points.map((p) => p.bestReps).reduce(_maxInt);

  int get longestSeconds =>
      points.isEmpty ? 0 : points.map((p) => p.bestSeconds).reduce(_maxInt);

  ProgressPoint? get last => points.isEmpty ? null : points.last;
}
