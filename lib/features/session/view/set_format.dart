import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/session_models.dart';

SetValues valuesOf(SetEntry set) => SetValues(
  reps: set.reps,
  weightKg: set.weightKg,
  durationSeconds: set.durationSeconds,
  distanceMeters: set.distanceMeters,
  isWarmup: set.isWarmup,
);

/// How the columns of a set row read for a tracking type.
class SetColumns {
  const SetColumns(this.l10n, this.type, this.unit);

  final AppLocalizations l10n;
  final TrackingType type;
  final WeightUnit unit;

  String get valueLabel => switch (type) {
    TrackingType.weightReps => l10n.unitLabel(unit),
    TrackingType.repsOnly => l10n.setColumnReps,
    TrackingType.duration => l10n.setColumnTime,
    TrackingType.distance => l10n.setColumnDistance,
  };

  String? get secondaryLabel => switch (type) {
    TrackingType.weightReps => l10n.setColumnReps,
    TrackingType.distance => l10n.setColumnTime,
    _ => null,
  };

  String value({
    double? weightKg,
    int? reps,
    int? durationSeconds,
    double? distanceMeters,
  }) {
    return switch (type) {
      TrackingType.weightReps =>
        weightKg == null ? '–' : formatWeight(weightKg, unit, l10n.localeName),
      TrackingType.repsOnly => reps == null ? '–' : '$reps',
      TrackingType.duration => _duration(durationSeconds),
      TrackingType.distance =>
        distanceMeters == null
            ? '–'
            : formatDecimal(
                distanceMeters / 1000,
                l10n.localeName,
                maxDecimals: 2,
              ),
    };
  }

  String? secondary({int? reps, int? durationSeconds}) => switch (type) {
    TrackingType.weightReps => reps == null ? '–' : '$reps',
    TrackingType.distance => _duration(durationSeconds),
    _ => null,
  };

  /// "Previous" cell: `60 × 8`, `× 12`, `1:00`, `5 km · 25:00`.
  String previous(PerformedSet? set) {
    if (set == null) return '–';
    return switch (type) {
      TrackingType.weightReps =>
        '${set.weightKg == null ? '–' : formatWeight(set.weightKg!, unit, l10n.localeName)} × ${set.reps ?? '–'}',
      TrackingType.repsOnly => '× ${set.reps ?? '–'}',
      TrackingType.duration => _duration(set.durationSeconds),
      TrackingType.distance =>
        '${value(distanceMeters: set.distanceMeters)} · ${_duration(set.durationSeconds)}',
    };
  }

  static String _duration(int? seconds) =>
      seconds == null ? '–' : formatClock(Duration(seconds: seconds));
}
