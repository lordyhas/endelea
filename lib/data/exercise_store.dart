import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../utils/ids.dart';
import 'exercise_catalog.dart';

/// Built-in exercises plus the ones created by the user.
class ExerciseStore extends ChangeNotifier {
  ExerciseStore({List<Exercise>? custom}) : _custom = custom ?? [];

  final List<Exercise> _custom;

  /// Every exercise, sorted by name.
  List<Exercise> get all => List.unmodifiable(
    [...exerciseCatalog, ..._custom]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
  );

  List<Exercise> get custom => List.unmodifiable(_custom);

  Exercise? byId(String id) {
    for (final exercise in _custom) {
      if (exercise.id == id) return exercise;
    }
    return exerciseById(id);
  }

  Exercise add({
    required String name,
    required MuscleGroup muscleGroup,
    required Equipment equipment,
    required TrainingPlace place,
    required TrackingType tracking,
    String description = '',
  }) {
    final exercise = Exercise(
      id: newId('custom'),
      name: name,
      muscleGroup: muscleGroup,
      equipment: equipment,
      place: place,
      tracking: tracking,
      description: description,
      custom: true,
    );
    _custom.add(exercise);
    notifyListeners();
    return exercise;
  }

  /// Removes every custom exercise.
  void clear() {
    _custom.clear();
    notifyListeners();
  }

  /// Removes a custom exercise. Built-in exercises cannot be removed.
  void remove(Exercise exercise) {
    if (_custom.remove(exercise)) notifyListeners();
  }
}
