import 'dart:math' as math;

import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/one_rep_max.dart';
import 'package:endelea/domain/progress/volume.dart';
import 'package:equatable/equatable.dart';

/// Kinds of personal record (PLAN.md §5.2).
enum RecordType { maxWeight, estimatedOneRepMax, repsAtWeight, sessionVolume }

/// Best performances of one exercise over a set of finished sessions.
class PersonalRecords extends Equatable {
  const PersonalRecords({
    this.maxWeightKg,
    this.bestOneRepMaxKg,
    this.maxRepsAtWeight = const {},
    this.bestSessionVolumeKg,
    this.maxReps,
  });

  /// Builds the records of one exercise from its working sets.
  factory PersonalRecords.fromSets(Iterable<PerformedSet> sets) {
    double? maxWeight;
    double? bestOneRm;
    int? maxReps;
    final repsAtWeight = <double, int>{};
    final volumeBySession = <String, double>{};

    for (final set in sets) {
      if (set.isWarmup) continue;
      final weight = set.weightKg;
      final reps = set.reps;
      if (weight != null && weight > 0) {
        maxWeight = math.max(maxWeight ?? weight, weight);
      }
      final oneRm = estimatedOneRepMax(weight, reps);
      if (oneRm != null) bestOneRm = math.max(bestOneRm ?? oneRm, oneRm);
      if (reps != null) {
        maxReps = math.max(maxReps ?? reps, reps);
        final key = weightKey(weight);
        repsAtWeight[key] = math.max(repsAtWeight[key] ?? reps, reps);
      }
      volumeBySession.update(
        set.sessionId,
        (v) => v + performedVolume(set),
        ifAbsent: () => performedVolume(set),
      );
    }
    final volumes = volumeBySession.values.where((v) => v > 0);
    return PersonalRecords(
      maxWeightKg: maxWeight,
      bestOneRepMaxKg: bestOneRm,
      maxRepsAtWeight: repsAtWeight,
      bestSessionVolumeKg: volumes.isEmpty ? null : volumes.reduce(math.max),
      maxReps: maxReps,
    );
  }

  static const empty = PersonalRecords();

  final double? maxWeightKg;
  final double? bestOneRepMaxKg;

  /// Best reps for each weight (kg rounded to 0.01; 0 for no weight).
  final Map<double, int> maxRepsAtWeight;
  final double? bestSessionVolumeKg;
  final int? maxReps;

  bool get isEmpty =>
      maxWeightKg == null && maxReps == null && bestSessionVolumeKg == null;

  static double weightKey(double? weightKg) =>
      ((weightKg ?? 0) * 100).roundToDouble() / 100;

  /// Records a new working set beats. Nothing is a record the first time
  /// an exercise is done.
  ///
  /// [sessionVolumeKg] is the volume of the exercise in the current
  /// session, this set included.
  Set<RecordType> beatenBy({
    required SetValues set,
    required TrackingType trackingType,
    required double sessionVolumeKg,
  }) {
    if (isEmpty || set.isWarmup) return const {};
    final records = <RecordType>{};
    final weight = set.weightKg;
    final reps = set.reps;
    if (trackingType.usesWeight && weight != null && weight > 0) {
      final max = maxWeightKg;
      if (max != null && weight > max + 1e-9) records.add(RecordType.maxWeight);
      final oneRm = estimatedOneRepMax(weight, reps);
      final best = bestOneRepMaxKg;
      if (oneRm != null && best != null && oneRm > best + 1e-9) {
        records.add(RecordType.estimatedOneRepMax);
      }
      final volume = bestSessionVolumeKg;
      if (volume != null && sessionVolumeKg > volume + 1e-9) {
        records.add(RecordType.sessionVolume);
      }
    }
    if (trackingType.usesReps && reps != null) {
      final best = maxRepsAtWeight[weightKey(weight)];
      if (best != null && reps > best) records.add(RecordType.repsAtWeight);
    }
    return records;
  }

  @override
  List<Object?> get props => [
    maxWeightKg,
    bestOneRepMaxKg,
    maxRepsAtWeight,
    bestSessionVolumeKg,
    maxReps,
  ];
}

/// Sets of [exerciseId] grouped by session, oldest session first.
Map<String, List<PerformedSet>> setsBySession(
  Iterable<PerformedSet> history,
  String exerciseId,
) {
  final result = <String, List<PerformedSet>>{};
  for (final set in history) {
    if (set.exerciseId != exerciseId) continue;
    (result[set.sessionId] ??= []).add(set);
  }
  return result;
}

/// "Previous" values: the sets of the last finished session containing
/// [exerciseId], in set order (PLAN.md §5.2). [history] is sorted oldest
/// first.
List<PerformedSet> previousSets(
  Iterable<PerformedSet> history,
  String exerciseId,
) {
  final sessions = setsBySession(history, exerciseId);
  if (sessions.isEmpty) return const [];
  return [...sessions.values.last]
    ..sort((a, b) => a.setIndex.compareTo(b.setIndex));
}
