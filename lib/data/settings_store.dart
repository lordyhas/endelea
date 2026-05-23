import 'package:flutter/material.dart' show ChangeNotifier, ThemeMode;

import '../models/settings.dart';

/// Holds the user preferences, in memory for now.
class SettingsStore extends ChangeNotifier {
  SettingsStore([this._settings = const AppSettings()]);

  AppSettings _settings;

  AppSettings get settings => _settings;

  set weightUnit(WeightUnit unit) {
    _settings = _settings.copyWith(weightUnit: unit);
    notifyListeners();
  }

  set themeMode(ThemeMode mode) {
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
  }

  set restDuration(Duration duration) {
    _settings = _settings.copyWith(restDuration: duration);
    notifyListeners();
  }
}
