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

class AppSettings {
  const AppSettings({
    this.weightUnit = WeightUnit.kg,
    this.restDuration = const Duration(seconds: 90),
  });

  final WeightUnit weightUnit;
  final Duration restDuration;

  AppSettings copyWith({WeightUnit? weightUnit, Duration? restDuration}) =>
      AppSettings(
        weightUnit: weightUnit ?? this.weightUnit,
        restDuration: restDuration ?? this.restDuration,
      );
}
