import 'package:endelea/domain/models/session_models.dart';

/// Volume of one set: `weight × reps`. Warm-up sets count for nothing.
double setVolume({
  required double? weightKg,
  required int? reps,
  bool isWarmup = false,
}) {
  if (isWarmup || weightKg == null || reps == null) return 0;
  return weightKg * reps;
}

double performedVolume(PerformedSet set) =>
    setVolume(weightKg: set.weightKg, reps: set.reps, isWarmup: set.isWarmup);

/// Total volume of [sets].
double totalVolume(Iterable<PerformedSet> sets) =>
    sets.fold(0, (sum, set) => sum + performedVolume(set));
