import 'package:flutter/material.dart' show ThemeMode;

/// Unit used to show and enter weights. Weights are stored in kg.
enum WeightUnit {
  kg('kg', 1),
  lb('lb', 2.20462);

  const WeightUnit(this.label, this.perKg);

  final String label;

  /// How many of this unit make one kilogram.
  final double perKg;

  /// Converts a weight stored in kilograms to this unit.
  double fromKg(double kg) => kg * perKg;

  /// Converts a weight entered in this unit to kilograms.
  double toKg(double value) => value / perKg;
}

/// User preferences, saved on the device.
class AppSettings {
  const AppSettings({
    this.weightUnit = WeightUnit.kg,
    this.restDuration = const Duration(seconds: 90),
    this.themeMode = ThemeMode.system,
    this.weeklyGoal = 3,
    this.lastBackupAt,
  });

  final WeightUnit weightUnit;
  final Duration restDuration;
  final ThemeMode themeMode;

  /// Number of workouts the user aims for each week.
  final int weeklyGoal;

  /// When the data was last backed up to the cloud.
  final DateTime? lastBackupAt;

  AppSettings copyWith({
    WeightUnit? weightUnit,
    Duration? restDuration,
    ThemeMode? themeMode,
    int? weeklyGoal,
    DateTime? lastBackupAt,
  }) => AppSettings(
    weightUnit: weightUnit ?? this.weightUnit,
    restDuration: restDuration ?? this.restDuration,
    themeMode: themeMode ?? this.themeMode,
    weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    lastBackupAt: lastBackupAt ?? this.lastBackupAt,
  );

  /// Missing or unknown values fall back to the defaults.
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    const defaults = AppSettings();
    final rest = json['restSeconds'] as int?;
    final lastBackupAt = json['lastBackupAt'] as String?;
    return AppSettings(
      weightUnit:
          WeightUnit.values.asNameMap()[json['weightUnit']] ??
          defaults.weightUnit,
      restDuration: rest == null
          ? defaults.restDuration
          : Duration(seconds: rest),
      themeMode:
          ThemeMode.values.asNameMap()[json['themeMode']] ?? defaults.themeMode,
      weeklyGoal: json['weeklyGoal'] as int? ?? defaults.weeklyGoal,
      lastBackupAt: lastBackupAt == null
          ? null
          : DateTime.tryParse(lastBackupAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'weightUnit': weightUnit.name,
    'restSeconds': restDuration.inSeconds,
    'themeMode': themeMode.name,
    'weeklyGoal': weeklyGoal,
    'lastBackupAt': lastBackupAt?.toIso8601String(),
  };
}
