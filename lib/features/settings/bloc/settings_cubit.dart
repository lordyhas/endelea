import 'package:endelea/core/utils/units.dart';
import 'package:endelea/features/settings/data/app_settings.dart';
import 'package:endelea/features/settings/data/settings_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

sealed class SettingsState extends Equatable {
  const SettingsState(this.settings);

  final AppSettings settings;

  @override
  List<Object?> get props => [settings];
}

/// Settings are read synchronously at startup, so there is no loading state.
final class SettingsLoaded extends SettingsState {
  const SettingsLoaded(super.settings);
}

/// Global user preferences.
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(SettingsLoaded(_repository.load()));

  final SettingsRepository _repository;

  AppSettings get settings => state.settings;

  Future<void> _update(AppSettings settings) async {
    emit(SettingsLoaded(settings));
    await _repository.save(settings);
  }

  /// Switching units also resets a custom step, which was in the old unit.
  Future<void> setUnit(WeightUnit unit) => _update(
    settings.copyWith(unit: unit, clearWeightStep: unit != settings.unit),
  );

  Future<void> setWeightStep(double step) =>
      _update(settings.copyWith(weightStep: step));

  Future<void> setDefaultRest(int seconds) =>
      _update(settings.copyWith(defaultRestSeconds: seconds));

  Future<void> setProgressionSuggestion({required bool enabled}) =>
      _update(settings.copyWith(progressionSuggestion: enabled));

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(settings.copyWith(themeMode: mode));

  Future<void> setLanguage(String languageCode) =>
      _update(settings.copyWith(languageCode: languageCode));

  Future<void> setKeepScreenOn({required bool enabled}) =>
      _update(settings.copyWith(keepScreenOn: enabled));

  Future<void> setRestSound({required bool enabled}) =>
      _update(settings.copyWith(restSound: enabled));

  Future<void> setRestVibration({required bool enabled}) =>
      _update(settings.copyWith(restVibration: enabled));
}
