import 'package:flutter/material.dart' show ChangeNotifier, ThemeMode;

import '../models/settings.dart';

/// Holds the user preferences.
class SettingsStore extends ChangeNotifier {
  SettingsStore([this._settings = const AppSettings()]);

  AppSettings _settings;

  AppSettings get settings => _settings;

  set settings(AppSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  void reset() => settings = const AppSettings();

  set weightUnit(WeightUnit unit) {
    _settings = _settings.copyWith(weightUnit: unit);
    notifyListeners();
  }

  set themeMode(ThemeMode mode) {
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
  }

  set lastBackupAt(DateTime date) {
    _settings = _settings.copyWith(lastBackupAt: date);
    notifyListeners();
  }

  set restDuration(Duration duration) {
    _settings = _settings.copyWith(restDuration: duration);
    notifyListeners();
  }
}
