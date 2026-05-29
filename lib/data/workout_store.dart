import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_template.dart';
import 'rest_timer.dart';

/// In-memory store for the active workout and the workout history.
class WorkoutStore extends ChangeNotifier {
  WorkoutStore({List<Workout>? history, this._active})
    : _history = history ?? [];

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

  /// Starts a workout prefilled with the exercises and set count of
  /// [template].
  Workout startFromTemplate(WorkoutTemplate template) {
    final workout = start(name: template.name, place: template.place);
    for (final entry in template.exercises) {
      workout.exercises.add(
        WorkoutExercise(
          exercise: entry.exercise,
          sets: List.generate(entry.sets, (_) => WorkoutSet()),
        ),
      );
    }
    notifyListeners();
    return workout;
  }

  /// Starts a new workout with the same exercises and set values as [past].
  Workout repeat(Workout past) {
    final workout = start(name: past.name, place: past.place);
    for (final entry in past.exercises) {
      workout.exercises.add(
        WorkoutExercise(
          exercise: entry.exercise,
          sets: [for (final set in entry.sets) set.copy()..done = false],
        ),
      );
    }
    notifyListeners();
    return workout;
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

  /// Removes a finished workout from the history.
  void delete(Workout workout) {
    if (_history.remove(workout)) notifyListeners();
  }

  /// Call after mutating an exercise or a set of the active workout.
  void touch() => notifyListeners();

  @override
  void dispose() {
    restTimer.dispose();
    super.dispose();
  }
}
