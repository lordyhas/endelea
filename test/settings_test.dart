import 'package:endelea/data/settings_store.dart';
import 'package:endelea/models/settings.dart';
import 'package:endelea/utils/format.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeightUnit', () {
    test('converts between kilograms and pounds', () {
      expect(WeightUnit.kg.fromKg(60), 60);
      expect(WeightUnit.lb.fromKg(100), closeTo(220.46, 0.01));
      expect(
        WeightUnit.lb.toKg(WeightUnit.lb.fromKg(42.5)),
        closeTo(42.5, 1e-9),
      );
    });
  });

  group('formatWeight', () {
    test('formats in pounds', () {
      expect(formatWeight(60, WeightUnit.lb), '132.3 lb');
      expect(formatWeight(1000, WeightUnit.lb), '2.2k lb');
    });

    test('keeps kilograms as the default unit', () {
      expect(formatWeight(60), '60 kg');
    });
  });

  test('formatNumber keeps at most one decimal', () {
    expect(formatNumber(20), '20');
    expect(formatNumber(12.25), '12.3');
    expect(formatNumber(132.277), '132.3');
  });

  group('SettingsStore', () {
    test('starts with kg and a 90 seconds rest', () {
      final store = SettingsStore();

      expect(store.settings.weightUnit, WeightUnit.kg);
      expect(store.settings.restDuration, const Duration(seconds: 90));
      expect(store.settings.themeMode, ThemeMode.system);
    });

    test('notifies listeners when a preference changes', () {
      final store = SettingsStore();
      var notified = 0;
      store.addListener(() => notified++);

      store.weightUnit = WeightUnit.lb;
      store.restDuration = const Duration(minutes: 2);
      store.themeMode = ThemeMode.dark;

      expect(notified, 3);
      expect(store.settings.themeMode, ThemeMode.dark);
      expect(store.settings.weightUnit, WeightUnit.lb);
      expect(store.settings.restDuration, const Duration(minutes: 2));
    });

    test('keeps the weekly goal between 1 and 7', () {
      final store = SettingsStore();
      expect(store.settings.weeklyGoal, 3);

      store.weeklyGoal = 10;
      expect(store.settings.weeklyGoal, 7);

      store.weeklyGoal = 0;
      expect(store.settings.weeklyGoal, 1);
    });

    test('saves the weekly goal in json', () {
      final settings = AppSettings.fromJson(
        const AppSettings(weeklyGoal: 5).toJson(),
      );

      expect(settings.weeklyGoal, 5);
      expect(AppSettings.fromJson({}).weeklyGoal, 3);
    });
  });
}
