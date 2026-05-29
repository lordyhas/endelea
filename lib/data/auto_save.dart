import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_repository.dart';
import 'exercise_store.dart';
import 'settings_store.dart';
import 'template_store.dart';
import 'workout_store.dart';

/// Writes a store to the repository shortly after it changes.
///
/// Changes are grouped with a short delay so typing in a set does not
/// write a file for every key press.
class AutoSave {
  AutoSave({
    required this.repository,
    required this.workouts,
    required this.settings,
    required this.exercises,
    required this.templates,
    this.delay = const Duration(milliseconds: 500),
  }) {
    workouts.addListener(_workoutsChanged);
    settings.addListener(_settingsChanged);
    exercises.addListener(_exercisesChanged);
    templates.addListener(_templatesChanged);
  }

  final AppRepository repository;
  final WorkoutStore workouts;
  final SettingsStore settings;
  final ExerciseStore exercises;
  final TemplateStore templates;
  final Duration delay;

  final Map<String, Future<void> Function()> _pending = {};
  Timer? _timer;

  void _schedule(String key, Future<void> Function() save) {
    _pending[key] = save;
    _timer?.cancel();
    _timer = Timer(delay, flush);
  }

  void _workoutsChanged() => _schedule('workouts', () async {
    await repository.saveHistory(workouts.history);
    await repository.saveActive(workouts.active);
  });

  void _settingsChanged() =>
      _schedule('settings', () => repository.saveSettings(settings.settings));

  void _exercisesChanged() => _schedule(
    'exercises',
    () => repository.saveCustomExercises(exercises.custom),
  );

  void _templatesChanged() => _schedule(
    'templates',
    () => repository.saveRoutines(templates.templates),
  );

  /// Writes every pending change now.
  Future<void> flush() async {
    _timer?.cancel();
    final saves = _pending.values.toList();
    _pending.clear();
    for (final save in saves) {
      try {
        await save();
      } catch (error) {
        debugPrint('Could not save data: $error');
      }
    }
  }

  void dispose() {
    _timer?.cancel();
    workouts.removeListener(_workoutsChanged);
    settings.removeListener(_settingsChanged);
    exercises.removeListener(_exercisesChanged);
    templates.removeListener(_templatesChanged);
  }
}
