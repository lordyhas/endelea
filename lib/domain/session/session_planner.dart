import 'dart:math' as math;

import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/personal_records.dart';

/// Weight added when every set of the last session reached the top of the
/// rep range (PLAN.md §5.2): 2.5 kg for a barbell, 1 kg for dumbbells,
/// machines, cables and kettlebells, nothing otherwise.
double progressionIncrementKg(Equipment? equipment) => switch (equipment) {
  Equipment.barbell => 2.5,
  Equipment.dumbbell ||
  Equipment.machine ||
  Equipment.cable ||
  Equipment.kettlebell => 1,
  _ => 0,
};

/// Weight to pre-fill for the next session of an exercise.
///
/// Without history, the target weight. Otherwise the heaviest working
/// weight of the last session, plus the increment when every working set
/// reached [targetRepsMax] and the suggestion is [enabled].
double? suggestWeightKg({
  required List<PerformedSet> lastSets,
  required Equipment? equipment,
  required bool enabled,
  int? targetRepsMax,
  double? targetWeightKg,
}) {
  final working = lastSets.where((s) => !s.isWarmup).toList();
  final weights = working.map((s) => s.weightKg).whereType<double>();
  if (weights.isEmpty) return targetWeightKg;
  final base = weights.reduce(math.max);
  final reachedTop =
      targetRepsMax != null &&
      working.every((s) => (s.reps ?? 0) >= targetRepsMax);
  if (enabled && reachedTop) return base + progressionIncrementKg(equipment);
  return base;
}

/// Turns the planned exercises of a day into the pre-filled exercises of a
/// new session.
List<PlannedSessionExercise> planSession({
  required List<PlannedExercise> planned,
  required List<PerformedSet> history,
  required bool progressionSuggestion,
}) {
  return [
    for (final item in planned)
      _planExercise(
        item,
        previousSets(history, item.exercise.id),
        progressionSuggestion,
      ),
  ];
}

PlannedSessionExercise _planExercise(
  PlannedExercise item,
  List<PerformedSet> last,
  bool progressionSuggestion,
) {
  final plan = item.plan;
  final type = TrackingType.fromKey(item.exercise.trackingType);
  final weight = type.usesWeight
      ? suggestWeightKg(
          lastSets: last,
          equipment: Equipment.fromKey(item.exercise.equipment),
          enabled: progressionSuggestion,
          targetRepsMax: plan.targetRepsMax,
          targetWeightKg: plan.targetWeightKg,
        )
      : null;
  final lastWorking = last.where((s) => !s.isWarmup).toList();
  final lastWeight = lastWorking.isEmpty ? null : lastWorking.first.weightKg;
  final sameWeight = weight == lastWeight;
  final targetReps = plan.targetRepsMin ?? plan.targetRepsMax;

  return PlannedSessionExercise(
    exerciseId: item.exercise.id,
    programExerciseId: plan.id,
    targetRepsMin: plan.targetRepsMin,
    targetRepsMax: plan.targetRepsMax,
    restSeconds: plan.restSeconds,
    notes: plan.notes,
    sets: [
      for (var i = 0; i < plan.targetSets; i++)
        SetValues(
          weightKg: weight,
          // Same weight as last time: aim for last time's reps of this set.
          reps: type.usesReps
              ? (sameWeight && i < lastWorking.length
                        ? lastWorking[i].reps
                        : null) ??
                    targetReps
              : null,
          durationSeconds: type.usesDuration
              ? plan.targetDurationSeconds ??
                    (i < lastWorking.length
                        ? lastWorking[i].durationSeconds
                        : null)
              : null,
          distanceMeters: type.usesDistance && i < lastWorking.length
              ? lastWorking[i].distanceMeters
              : null,
        ),
    ],
  );
}

/// An exercise added during a session: three sets pre-filled from the last
/// time it was done.
PlannedSessionExercise planAddedExercise({
  required String exerciseId,
  required TrackingType trackingType,
  required List<PerformedSet> history,
  required int restSeconds,
}) {
  final last = previousSets(
    history,
    exerciseId,
  ).where((s) => !s.isWarmup).toList();
  final count = last.isEmpty ? 3 : last.length;
  return PlannedSessionExercise(
    exerciseId: exerciseId,
    restSeconds: restSeconds,
    sets: [
      for (var i = 0; i < count; i++)
        SetValues(
          weightKg: trackingType.usesWeight && i < last.length
              ? last[i].weightKg
              : null,
          reps: trackingType.usesReps
              ? (i < last.length ? last[i].reps : null) ?? 10
              : null,
          durationSeconds: trackingType.usesDuration
              ? (i < last.length ? last[i].durationSeconds : null) ?? 60
              : null,
          distanceMeters: trackingType.usesDistance && i < last.length
              ? last[i].distanceMeters
              : null,
        ),
    ],
  );
}
