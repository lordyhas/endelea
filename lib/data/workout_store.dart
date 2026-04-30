import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/workout.dart';

/// In-memory store for the active workout and the workout history.
class WorkoutStore extends ChangeNotifier {
  WorkoutStore({List<Workout>? history}) : _history = history ?? [];

  final List<Workout> _history;
  Workout? _active;

  Workout? get active => _active;

  /// Finished workouts, most recent first.
  List<Workout> get history => List.unmodifiable(
    [..._history]..sort((a, b) => b.startedAt.compareTo(a.startedAt)),
  );

  Workout start({required String name, required TrainingPlace place}) {
    final now = DateTime.now();
    _active = Workout(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      place: place,
      startedAt: now,
    );
    notifyListeners();
    return _active!;
  }

  void addExercise(Exercise exercise) {
    final workout = _active;
    if (workout == null) return;
    workout.exercises.add(WorkoutExercise(exercise: exercise));
    notifyListeners();
  }

  void removeExercise(WorkoutExercise entry) {
    _active?.exercises.remove(entry);
    notifyListeners();
  }

  /// Call after mutating an exercise or a set of the active workout.
  void touch() => notifyListeners();
}
