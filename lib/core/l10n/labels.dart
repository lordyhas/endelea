import 'package:endelea/core/l10n/exercise_names.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

extension ExerciseLabels on AppLocalizations {
  /// Built-ins use the ARB name, custom exercises their own name.
  String exerciseName(Exercise exercise) {
    final key = exercise.builtInKey;
    return (key == null ? null : builtInExerciseName(this, key)) ??
        exercise.name;
  }

  String muscleGroup(MuscleGroup group) => switch (group) {
    MuscleGroup.chest => muscleChest,
    MuscleGroup.back => muscleBack,
    MuscleGroup.shoulders => muscleShoulders,
    MuscleGroup.biceps => muscleBiceps,
    MuscleGroup.triceps => muscleTriceps,
    MuscleGroup.legs => muscleLegs,
    MuscleGroup.glutes => muscleGlutes,
    MuscleGroup.core => muscleCore,
    MuscleGroup.cardio => muscleCardio,
    MuscleGroup.fullBody => muscleFullBody,
  };

  String equipment(Equipment equipment) => switch (equipment) {
    Equipment.barbell => equipmentBarbell,
    Equipment.dumbbell => equipmentDumbbell,
    Equipment.machine => equipmentMachine,
    Equipment.cable => equipmentCable,
    Equipment.bodyweight => equipmentBodyweight,
    Equipment.kettlebell => equipmentKettlebell,
    Equipment.band => equipmentBand,
    Equipment.other => equipmentOther,
  };

  String trackingType(TrackingType type) => switch (type) {
    TrackingType.weightReps => trackingWeightReps,
    TrackingType.repsOnly => trackingRepsOnly,
    TrackingType.duration => trackingDuration,
    TrackingType.distance => trackingDistance,
  };
}

extension MuscleGroupIcon on MuscleGroup? {
  IconData get icon => switch (this) {
    MuscleGroup.chest => PhosphorIconsRegular.barbell,
    MuscleGroup.back => PhosphorIconsRegular.arrowsVertical,
    MuscleGroup.shoulders => PhosphorIconsRegular.arrowsOutCardinal,
    MuscleGroup.biceps => PhosphorIconsRegular.handFist,
    MuscleGroup.triceps => PhosphorIconsRegular.hand,
    MuscleGroup.legs => PhosphorIconsRegular.sneakerMove,
    MuscleGroup.glutes => PhosphorIconsRegular.personSimpleWalk,
    MuscleGroup.core => PhosphorIconsRegular.target,
    MuscleGroup.cardio => PhosphorIconsRegular.heartbeat,
    MuscleGroup.fullBody => PhosphorIconsRegular.personArmsSpread,
    null => PhosphorIconsRegular.barbell,
  };
}
