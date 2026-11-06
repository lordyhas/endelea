import 'package:endelea/core/utils/units.dart';
import 'package:endelea/features/settings/data/app_settings.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes [AppSettings] in shared_preferences.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _unit = 'unit';
  static const _weightStep = 'weightStep';
  static const _defaultRest = 'defaultRestSeconds';
  static const _progression = 'progressionSuggestion';
  static const _theme = 'themeMode';
  static const _language = 'languageCode';
  static const _keepScreenOn = 'keepScreenOn';
  static const _restSound = 'restSound';
  static const _restVibration = 'restVibration';

  static Future<SettingsRepository> open() async =>
      SettingsRepository(await SharedPreferences.getInstance());

  AppSettings load() {
    const defaults = AppSettings();
    return AppSettings(
      unit: WeightUnit.fromKey(_prefs.getString(_unit)),
      weightStep: _prefs.getDouble(_weightStep),
      defaultRestSeconds:
          _prefs.getInt(_defaultRest) ?? defaults.defaultRestSeconds,
      progressionSuggestion:
          _prefs.getBool(_progression) ?? defaults.progressionSuggestion,
      themeMode:
          ThemeMode.values
              .where((m) => m.name == _prefs.getString(_theme))
              .firstOrNull ??
          defaults.themeMode,
      languageCode: _prefs.getString(_language) ?? defaults.languageCode,
      keepScreenOn: _prefs.getBool(_keepScreenOn) ?? defaults.keepScreenOn,
      restSound: _prefs.getBool(_restSound) ?? defaults.restSound,
      restVibration: _prefs.getBool(_restVibration) ?? defaults.restVibration,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_unit, settings.unit.key);
    final step = settings.weightStep;
    if (step == null) {
      await _prefs.remove(_weightStep);
    } else {
      await _prefs.setDouble(_weightStep, step);
    }
    await _prefs.setInt(_defaultRest, settings.defaultRestSeconds);
    await _prefs.setBool(_progression, settings.progressionSuggestion);
    await _prefs.setString(_theme, settings.themeMode.name);
    await _prefs.setString(_language, settings.languageCode);
    await _prefs.setBool(_keepScreenOn, settings.keepScreenOn);
    await _prefs.setBool(_restSound, settings.restSound);
    await _prefs.setBool(_restVibration, settings.restVibration);
  }
}
