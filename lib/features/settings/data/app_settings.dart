import 'package:endelea/core/utils/units.dart';
import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

/// User preferences (PLAN.md §8.10). UI settings only: stored in
/// shared_preferences, never synced.
class AppSettings extends Equatable {
  const AppSettings({
    this.unit = WeightUnit.kg,
    this.weightStep,
    this.defaultRestSeconds = 90,
    this.progressionSuggestion = true,
    this.themeMode = ThemeMode.dark,
    this.languageCode = 'fr',
    this.keepScreenOn = true,
    this.restSound = true,
    this.restVibration = true,
  });

  final WeightUnit unit;

  /// +/- step in [unit]; null means the unit default (2.5 kg / 5 lb).
  final double? weightStep;
  final int defaultRestSeconds;
  final bool progressionSuggestion;
  final ThemeMode themeMode;

  /// `fr` or `en`.
  final String languageCode;

  /// Keep the screen on during a session.
  final bool keepScreenOn;
  final bool restSound;
  final bool restVibration;

  double get effectiveWeightStep => weightStep ?? unit.defaultStep;

  AppSettings copyWith({
    WeightUnit? unit,
    double? weightStep,
    bool clearWeightStep = false,
    int? defaultRestSeconds,
    bool? progressionSuggestion,
    ThemeMode? themeMode,
    String? languageCode,
    bool? keepScreenOn,
    bool? restSound,
    bool? restVibration,
  }) {
    return AppSettings(
      unit: unit ?? this.unit,
      weightStep: clearWeightStep ? null : weightStep ?? this.weightStep,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      progressionSuggestion:
          progressionSuggestion ?? this.progressionSuggestion,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      restSound: restSound ?? this.restSound,
      restVibration: restVibration ?? this.restVibration,
    );
  }

  @override
  List<Object?> get props => [
    unit,
    weightStep,
    defaultRestSeconds,
    progressionSuggestion,
    themeMode,
    languageCode,
    keepScreenOn,
    restSound,
    restVibration,
  ];
}
