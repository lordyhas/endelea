/// Estimated one-rep max (Epley): `weight × (1 + reps / 30)`.
///
/// Only computed for 1 ≤ reps ≤ 12, where the formula is meaningful
/// (PLAN.md §5.2); returns null otherwise.
double? estimatedOneRepMax(double? weightKg, int? reps) {
  if (weightKg == null || reps == null || weightKg <= 0) return null;
  if (reps < 1 || reps > 12) return null;
  if (reps == 1) return weightKg;
  return weightKg * (1 + reps / 30);
}
