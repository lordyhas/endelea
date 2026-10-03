import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../exercise_store.dart';
import '../export.dart';
import '../settings_store.dart';
import '../template_store.dart';
import '../workout_store.dart';
import 'cloud_sync_provider.dart';

/// Backs up the app data to a [CloudSyncProvider] and reads it back.
class BackupService extends ChangeNotifier {
  BackupService({
    required this.provider,
    required this.workouts,
    required this.settings,
    required this.exercises,
    required this.templates,
  });

  static const fileName = 'endelea-backup.json';

  final CloudSyncProvider provider;
  final WorkoutStore workouts;
  final SettingsStore settings;
  final ExerciseStore exercises;
  final TemplateStore templates;

  bool _busy = false;

  /// Whether a sign in, backup or restore is running.
  bool get busy => _busy;

  Future<T> _run<T>(Future<T> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> signIn() => _run(provider.signIn);

  Future<void> signOut() => _run(provider.signOut);

  /// Uploads every data of the app, signing in first if needed.
  Future<void> backUp() => _run(() async {
    if (!provider.isSignedIn) await provider.signIn();
    final text = exportData(
      workouts: workouts,
      settings: settings,
      exercises: exercises,
      templates: templates,
    );
    await provider.upload(fileName, utf8.encode(text));
    settings.lastBackupAt = DateTime.now();
  });

  /// Downloads the last backup, or returns null when there is none.
  Future<ExportedData?> download() => _run(() async {
    if (!provider.isSignedIn) await provider.signIn();
    final bytes = await provider.download(fileName);
    return bytes == null ? null : parseExport(utf8.decode(bytes));
  });

  /// Replaces the app data with [data], read by [download].
  void restore(ExportedData data) => restoreData(
    data,
    workouts: workouts,
    settings: settings,
    exercises: exercises,
    templates: templates,
  );
}
