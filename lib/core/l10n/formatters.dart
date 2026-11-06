import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

extension LocaleName on BuildContext {
  String get localeName => Localizations.localeOf(this).toString();
}

extension AppFormatters on AppLocalizations {
  String unitLabel(WeightUnit unit) => unit == WeightUnit.kg ? unitKg : unitLb;

  /// `62,5 kg`.
  String weightWithUnit(double kg, WeightUnit unit) =>
      '${formatWeight(kg, unit, localeName)} ${unitLabel(unit)}';

  /// `8–10`, `8`, or null.
  String? repsRange(int? min, int? max) {
    if (min == null && max == null) return null;
    if (min == null || max == null || min == max) return '${min ?? max}';
    return '$min–$max';
  }

  /// `4 × 8–10 · 60 kg · rest 1:30` (PLAN.md §8.4).
  String targetsSummary({
    required TrackingType trackingType,
    required int sets,
    required int restSeconds,
    required WeightUnit unit,
    int? repsMin,
    int? repsMax,
    double? weightKg,
    int? durationSeconds,
  }) {
    final reps = repsRange(repsMin, repsMax);
    final duration = durationSeconds == null
        ? null
        : formatClock(Duration(seconds: durationSeconds));
    final volume = trackingType.usesReps ? reps : duration;
    return [
      if (volume != null) setsTimesReps(sets, volume) else '$sets ×',
      if (trackingType.usesWeight && weightKg != null && weightKg > 0)
        weightWithUnit(weightKg, unit),
      restShort(formatClock(Duration(seconds: restSeconds))),
    ].join(' · ');
  }

  /// `18 nov.` (local date).
  String shortDate(DateTime date) =>
      DateFormat.MMMd(localeName).format(date.toLocal());

  /// `mardi 18 novembre`.
  String longDate(DateTime date) =>
      DateFormat.MMMMEEEEd(localeName).format(date.toLocal());

  /// `18:30`.
  String time(DateTime date) =>
      DateFormat.Hm(localeName).format(date.toLocal());
}
