import 'dart:convert';

import '../app/app_info.dart';
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
