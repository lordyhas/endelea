import 'package:intl/intl.dart';

/// Display unit for weights. Weights are always stored in kg (PLAN.md §5.3).
enum WeightUnit {
  kg('kg'),
  lb('lb');

  WeightUnit(this.key);

  final String key;

  static const double lbPerKg = 2.20462262185;

  /// Display rounding: 0.5 kg or 1 lb.
  double get displayPrecision => this == kg ? 0.5 : 1;

  /// Default +/- step: 2.5 kg or 5 lb.
  double get defaultStep => this == kg ? 2.5 : 5;

  static WeightUnit fromKey(String? key) =>
      values.where((u) => u.key == key).firstOrNull ?? kg;
}

/// Converts a stored kg value to [unit] without rounding.
double kgToUnit(double kg, WeightUnit unit) =>
    unit == WeightUnit.kg ? kg : kg * WeightUnit.lbPerKg;

/// Converts a stored kg value for display, rounded to the unit precision.
double kgToDisplay(double kg, WeightUnit unit) =>
    roundTo(kgToUnit(kg, unit), unit.displayPrecision);

/// Converts a value entered in [unit] to kg for storage.
///
/// A value entered in kg is stored as is; a value entered in lb is stored
/// with full precision so that switching units back and forth is lossless.
double displayToKg(double value, WeightUnit unit) =>
    unit == WeightUnit.kg ? value : value / WeightUnit.lbPerKg;

double roundTo(double value, double precision) =>
    (value / precision).round() * precision;

/// Formats a number with the locale's decimal separator, without trailing
/// zeros: `62,5`, `60`, `1 250`.
String formatDecimal(num value, String locale, {int maxDecimals = 1}) {
  final format = NumberFormat.decimalPattern(locale)
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = maxDecimals;
  return format.format(value);
}

/// Formats a stored kg weight in [unit]: `62,5`.
String formatWeight(double kg, WeightUnit unit, String locale) =>
    formatDecimal(kgToDisplay(kg, unit), locale);

/// `1:30`, `12:05`, `1:02:03`.
String formatClock(Duration duration) {
  final negative = duration.isNegative;
  final d = duration.abs();
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final body = hours > 0
      ? '$hours:${minutes.toString().padLeft(2, '0')}:$seconds'
      : '$minutes:$seconds';
  return negative ? '-$body' : body;
}
