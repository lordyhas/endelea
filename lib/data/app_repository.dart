import 'dart:convert';

import '../models/exercise.dart';
import '../models/settings.dart';
import 'storage/key_value_storage.dart';

/// Reads and writes the app data as json documents.
class AppRepository {
  AppRepository(this.storage);

  final KeyValueStorage storage;

  static const settingsKey = 'settings';
  static const exercisesKey = 'exercises';

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
}
