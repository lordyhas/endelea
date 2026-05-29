import 'dart:convert';

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

  Future<Object?> _readJson(String key) async {
    final text = await storage.read(key);
    return text == null ? null : jsonDecode(text);
  }

  Future<void> _writeJson(String key, Object? json) =>
      storage.write(key, jsonEncode(json));

  Future<AppSettings?> loadSettings() async {
    final json = await _readJson(settingsKey);
    return json == null
        ? null
        : AppSettings.fromJson(json as Map<String, dynamic>);
  }

  Future<void> saveSettings(AppSettings settings) =>
      _writeJson(settingsKey, settings.toJson());

  Future<List<Exercise>?> loadCustomExercises() async {
    final json = await _readJson(exercisesKey) as List?;
    return json
        ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustomExercises(List<Exercise> exercises) =>
      _writeJson(exercisesKey, [for (final e in exercises) e.toJson()]);

  Future<List<WorkoutTemplate>?> loadRoutines(ExerciseLookup lookup) async {
    final json = await _readJson(routinesKey) as List?;
    return json
        ?.map(
          (t) => WorkoutTemplate.fromJson(t as Map<String, dynamic>, lookup),
        )
        .toList();
  }

  Future<void> saveRoutines(List<WorkoutTemplate> routines) =>
      _writeJson(routinesKey, [for (final t in routines) t.toJson()]);

  Future<List<Workout>?> loadHistory(ExerciseLookup lookup) async {
    final json = await _readJson(historyKey) as List?;
    return json
        ?.map((w) => Workout.fromJson(w as Map<String, dynamic>, lookup))
        .toList();
  }

  Future<void> saveHistory(List<Workout> history) =>
      _writeJson(historyKey, [for (final w in history) w.toJson()]);
}
