/// Muscle groups (PLAN.md §4.3). [key] is the value stored in the database.
enum MuscleGroup {
  chest('chest'),
  back('back'),
  shoulders('shoulders'),
  biceps('biceps'),
  triceps('triceps'),
  legs('legs'),
  glutes('glutes'),
  core('core'),
  cardio('cardio'),
  fullBody('full_body');

  MuscleGroup(this.key);

  final String key;

  static MuscleGroup? fromKey(String? key) =>
      values.where((g) => g.key == key).firstOrNull;
}

enum Equipment {
  barbell('barbell'),
  dumbbell('dumbbell'),
  machine('machine'),
  cable('cable'),
  bodyweight('bodyweight'),
  kettlebell('kettlebell'),
  band('band'),
  other('other');

  Equipment(this.key);

  final String key;

  static Equipment? fromKey(String? key) =>
      values.where((e) => e.key == key).firstOrNull;
}

/// How an exercise is measured.
enum TrackingType {
  weightReps('weight_reps'),
  repsOnly('reps_only'),
  duration('duration'),
  distance('distance');

  TrackingType(this.key);

  final String key;

  bool get usesWeight => this == weightReps;
  bool get usesReps => this == weightReps || this == repsOnly;
  bool get usesDuration => this == duration || this == distance;
  bool get usesDistance => this == distance;

  static TrackingType fromKey(String? key) =>
      values.where((t) => t.key == key).firstOrNull ?? weightReps;
}
