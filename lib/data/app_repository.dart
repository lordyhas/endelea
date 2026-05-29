import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/settings.dart';
import '../models/workout.dart';
import '../models/workout_template.dart';
import 'storage/key_value_storage.dart';

/// Reads and writes the app data as json documents.
class AppRepository {
  AppRepository(this.storage);

  final KeyValueStorage storage;

  static const settingsKey = 'settings';
  static const exercisesKey = 'exercises';
  static const routinesKey = 'routines';
  static const historyKey = 'history';
  static const activeKey = 'active';

  /// Reads [key] and turns its json into a value with [parse].
  ///
  /// Unreadable data is kept under another key, so it is not lost when the
  /// app saves again, and null is returned as if nothing was saved.
  Future<T?> _load<T>(String key, T Function(Object json) parse) async {
    final text = await storage.read(key);
    if (text == null) return null;
    try {
      return parse(jsonDecode(text) as Object);
    } on Object catch (error) {
      debugPrint('Could not read $key: $error');
      await storage.write('$key-unreadable', text);
      return null;
    }
  }

  Future<void> _writeJson(String key, Object? json) =>
      storage.write(key, jsonEncode(json));

  static List<T> _list<T>(Object json, T Function(Map<String, dynamic>) item) =>
      [for (final e in json as List) item(e as Map<String, dynamic>)];

  Future<AppSettings?> loadSettings() => _load(
    settingsKey,
    (json) => AppSettings.fromJson(json as Map<String, dynamic>),
  );

  Future<void> saveSettings(AppSettings settings) =>
      _writeJson(settingsKey, settings.toJson());

  Future<List<Exercise>?> loadCustomExercises() =>
      _load(exercisesKey, (json) => _list(json, Exercise.fromJson));

  Future<void> saveCustomExercises(List<Exercise> exercises) =>
      _writeJson(exercisesKey, [for (final e in exercises) e.toJson()]);

  Future<List<WorkoutTemplate>?> loadRoutines(ExerciseLookup lookup) => _load(
    routinesKey,
    (json) => _list(json, (t) => WorkoutTemplate.fromJson(t, lookup)),
  );

  Future<void> saveRoutines(List<WorkoutTemplate> routines) =>
      _writeJson(routinesKey, [for (final t in routines) t.toJson()]);

  Future<List<Workout>?> loadHistory(ExerciseLookup lookup) => _load(
    historyKey,
    (json) => _list(json, (w) => Workout.fromJson(w, lookup)),
  );

  Future<void> saveHistory(List<Workout> history) =>
      _writeJson(historyKey, [for (final w in history) w.toJson()]);

  Future<Workout?> loadActive(ExerciseLookup lookup) => _load(
    activeKey,
    (json) => Workout.fromJson(json as Map<String, dynamic>, lookup),
  );

  /// Saves the workout in progress, or forgets it when [workout] is null.
  Future<void> saveActive(Workout? workout) => workout == null
      ? storage.delete(activeKey)
      : _writeJson(activeKey, workout.toJson());
}
