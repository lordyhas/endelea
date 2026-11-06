import 'package:bloc_test/bloc_test.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:endelea/features/settings/data/app_settings.dart';
import 'package:endelea/features/settings/data/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = await SettingsRepository.open();
  });

  test('defaults: kg, dark, French, 90 s rest', () {
    final settings = SettingsCubit(repository).settings;
    expect(settings, const AppSettings());
    expect(settings.effectiveWeightStep, 2.5);
  });

  blocTest<SettingsCubit, SettingsState>(
    'switching unit resets a custom step and persists',
    build: () => SettingsCubit(repository),
    act: (cubit) async {
      await cubit.setWeightStep(1.25);
      await cubit.setUnit(WeightUnit.lb);
    },
    expect: () => [
      const SettingsLoaded(AppSettings(weightStep: 1.25)),
      const SettingsLoaded(AppSettings(unit: WeightUnit.lb)),
    ],
    verify: (_) {
      expect(repository.load().unit, WeightUnit.lb);
      expect(repository.load().effectiveWeightStep, 5);
    },
  );

  blocTest<SettingsCubit, SettingsState>(
    'every preference is saved',
    build: () => SettingsCubit(repository),
    act: (cubit) async {
      await cubit.setDefaultRest(120);
      await cubit.setProgressionSuggestion(enabled: false);
      await cubit.setThemeMode(ThemeMode.light);
      await cubit.setLanguage('en');
      await cubit.setKeepScreenOn(enabled: false);
      await cubit.setRestSound(enabled: false);
      await cubit.setRestVibration(enabled: false);
    },
    skip: 6,
    expect: () => [
      const SettingsLoaded(
        AppSettings(
          defaultRestSeconds: 120,
          progressionSuggestion: false,
          themeMode: ThemeMode.light,
          languageCode: 'en',
          keepScreenOn: false,
          restSound: false,
          restVibration: false,
        ),
      ),
    ],
    verify: (cubit) => expect(repository.load(), cubit.settings),
  );
}
