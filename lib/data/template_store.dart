import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../models/workout_template.dart';
import '../utils/ids.dart';

/// List of workout templates.
class TemplateStore extends ChangeNotifier {
  TemplateStore({List<WorkoutTemplate>? templates})
    : _templates = templates ?? [];

  final List<WorkoutTemplate> _templates;

  List<WorkoutTemplate> get templates => List.unmodifiable(_templates);

  WorkoutTemplate create({
    required String name,
    required TrainingPlace place,
    List<TemplateExercise>? exercises,
  }) {
    final template = WorkoutTemplate(
      id: newId('tpl'),
      name: name,
      place: place,
      exercises: exercises,
    );
    _templates.add(template);
    notifyListeners();
    return template;
  }

  WorkoutTemplate saveWorkout(Workout workout) {
    final template = WorkoutTemplate.fromWorkout(workout, id: newId('tpl'));
    _templates.add(template);
    notifyListeners();
    return template;
  }

  /// Adds a copy of [template] right after it.
  WorkoutTemplate duplicate(WorkoutTemplate template) {
    final copy = WorkoutTemplate(
      id: newId('tpl'),
      name: '${template.name} (copy)',
      place: template.place,
      exercises: [
        for (final entry in template.exercises)
          TemplateExercise(exercise: entry.exercise, sets: entry.sets),
      ],
    );
    final index = _templates.indexOf(template);
    _templates.insert(index < 0 ? _templates.length : index + 1, copy);
    notifyListeners();
    return copy;
  }

  void remove(WorkoutTemplate template) {
    if (_templates.remove(template)) notifyListeners();
  }

  void clear() {
    _templates.clear();
    notifyListeners();
  }

  /// Call after mutating a template.
  void touch() => notifyListeners();
}
