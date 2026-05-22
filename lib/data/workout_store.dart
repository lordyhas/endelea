import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import 'rest_timer.dart';

/// In-memory store for the active workout and the workout history.
class WorkoutStore extends ChangeNotifier {
  WorkoutStore({List<Workout>? history}) : _history = history ?? [];

  final List<Workout> _history;
  Workout? _active;

  /// Rest countdown of the active workout. It lives here so it keeps
  /// running when the user leaves the workout screen.
  final RestTimer restTimer = RestTimer();

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

  /// Ends the active workout and saves it in the history.
  ///
  /// Sets that were not completed are dropped, as well as exercises left
  /// without any completed set. Returns the saved workout.
  Workout? finish() {
    final workout = _active;
    if (workout == null) return null;
    for (final entry in workout.exercises) {
      entry.sets.removeWhere((set) => !set.done);
    }
    workout.exercises.removeWhere((entry) => entry.sets.isEmpty);
    workout.finishedAt = DateTime.now();
    restTimer.stop();
    _history.add(workout);
    _active = null;
    notifyListeners();
    return workout;
  }

  /// Drops the active workout without saving it.
  void discard() {
    _active = null;
    restTimer.stop();
    notifyListeners();
  }

  /// Call after mutating an exercise or a set of the active workout.
  void touch() => notifyListeners();

  @override
  void dispose() {
    restTimer.dispose();
    super.dispose();
  }
}
