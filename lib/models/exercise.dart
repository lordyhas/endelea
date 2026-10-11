/// Main muscle group an exercise works.
enum MuscleGroup {
  chest('Chest'),
  back('Back'),
  shoulders('Shoulders'),
  arms('Arms'),
  legs('Legs'),
  core('Core'),
  fullBody('Full body'),
  cardio('Cardio');

  const MuscleGroup(this.label);

  final String label;
}

/// Equipment needed for an exercise.
enum Equipment {
  none('Bodyweight'),
  dumbbell('Dumbbell'),
  barbell('Barbell'),
  machine('Machine'),
  cable('Cable'),
  kettlebell('Kettlebell'),
  band('Resistance band');

  const Equipment(this.label);

  final String label;
}

/// Where an exercise can be performed.
enum TrainingPlace {
  gym('Gym'),
  home('Home'),
  both('Gym & home');

  const TrainingPlace(this.label);

  final String label;

  bool matches(TrainingPlace filter) =>
      this == both || filter == both || this == filter;
}

/// How a set of this exercise is measured.
enum TrackingType { weightReps, reps, duration }

/// An exercise from the built-in catalog.
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.place,
    this.tracking = TrackingType.weightReps,
    this.description = '',
  });

  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final Equipment equipment;
  final TrainingPlace place;
  final TrackingType tracking;
  final String description;

  @override
  bool operator ==(Object other) => other is Exercise && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
