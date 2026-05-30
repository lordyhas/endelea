import 'dart:convert';

import '../app/app_info.dart';
import '../models/exercise.dart';
import '../models/settings.dart';
import '../models/workout.dart';
import '../models/workout_template.dart';
import 'exercise_catalog.dart';
import 'exercise_store.dart';
import 'settings_store.dart';
import 'template_store.dart';
import 'workout_store.dart';

/// Every saved data of the app in one readable json document.
String exportData({
  required WorkoutStore workouts,
  required SettingsStore settings,
  required ExerciseStore exercises,
  required TemplateStore templates,
  DateTime? now,
}) => const JsonEncoder.withIndent('  ').convert({
  'app': AppInfo.name,
  'version': AppInfo.version,
  'exportedAt': (now ?? DateTime.now()).toIso8601String(),
  'settings': settings.settings.toJson(),
  'exercises': [for (final e in exercises.custom) e.toJson()],
  'routines': [for (final t in templates.templates) t.toJson()],
  'history': [for (final w in workouts.history) w.toJson()],
});

/// Data read back from an [exportData] document.
typedef ExportedData = ({
  AppSettings settings,
  List<Exercise> exercises,
  List<WorkoutTemplate> routines,
  List<Workout> history,
});

/// Reads a document made by [exportData].
///
/// Throws a [FormatException] when [text] is not such a document.
ExportedData parseExport(String text) {
  try {
    final json = jsonDecode(text) as Map<String, dynamic>;
    if (json['app'] != AppInfo.name) {
      throw const FormatException('Not an Endelea export');
    }
    final exercises = [
      for (final e in json['exercises'] as List)
        Exercise.fromJson(e as Map<String, dynamic>),
    ];
    Exercise? lookup(String id) =>
        exercises.where((e) => e.id == id).firstOrNull ?? exerciseById(id);
    return (
      settings: AppSettings.fromJson(json['settings'] as Map<String, dynamic>),
      exercises: exercises,
      routines: [
        for (final t in json['routines'] as List)
          WorkoutTemplate.fromJson(t as Map<String, dynamic>, lookup),
      ],
      history: [
        for (final w in json['history'] as List)
          Workout.fromJson(w as Map<String, dynamic>, lookup),
      ],
    );
  } on FormatException {
    rethrow;
  } on Object catch (error) {
    throw FormatException('Invalid export: $error');
  }
}

/// Puts [data] in the stores in place of their current content.
///
/// A workout in progress is kept.
void restoreData(
  ExportedData data, {
  required WorkoutStore workouts,
  required SettingsStore settings,
  required ExerciseStore exercises,
  required TemplateStore templates,
}) {
  exercises.replaceCustom(data.exercises);
  templates.replaceAll(data.routines);
  workouts.replaceHistory(data.history);
  settings.settings = data.settings;
}
