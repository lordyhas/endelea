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

/// Finds an exercise from its id, used when reading saved data.
typedef ExerciseLookup = Exercise? Function(String id);

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.place,
    this.tracking = TrackingType.weightReps,
    this.description = '',
    this.custom = false,
  });

  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final Equipment equipment;
  final TrainingPlace place;
  final TrackingType tracking;
  final String description;

  /// Whether the user created this exercise.
  final bool custom;

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as String,
    name: json['name'] as String,
    muscleGroup: MuscleGroup.values.byName(json['muscleGroup'] as String),
    equipment: Equipment.values.byName(json['equipment'] as String),
    place: TrainingPlace.values.byName(json['place'] as String),
    tracking: TrackingType.values.byName(json['tracking'] as String),
    description: json['description'] as String? ?? '',
    custom: json['custom'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'muscleGroup': muscleGroup.name,
    'equipment': equipment.name,
    'place': place.name,
    'tracking': tracking.name,
    'description': description,
    'custom': custom,
  };

  @override
  bool operator ==(Object other) => other is Exercise && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
