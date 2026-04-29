import '../models/exercise.dart';

/// Built-in exercises available out of the box.
const List<Exercise> exerciseCatalog = [
  // Gym
  Exercise(
    id: 'bench-press',
    name: 'Bench press',
    muscleGroup: MuscleGroup.chest,
    equipment: Equipment.barbell,
    place: TrainingPlace.gym,
    description: 'Lie on the bench, lower the bar to mid-chest and press up.',
  ),
  Exercise(
    id: 'back-squat',
    name: 'Back squat',
    muscleGroup: MuscleGroup.legs,
    equipment: Equipment.barbell,
    place: TrainingPlace.gym,
    description: 'Bar on the upper back, sit down between the hips and stand up.',
  ),
  Exercise(
    id: 'deadlift',
    name: 'Deadlift',
    muscleGroup: MuscleGroup.back,
    equipment: Equipment.barbell,
    place: TrainingPlace.gym,
    description: 'Hinge at the hips, keep the back flat and pull the bar up.',
  ),
  Exercise(
    id: 'lat-pulldown',
    name: 'Lat pulldown',
    muscleGroup: MuscleGroup.back,
    equipment: Equipment.cable,
    place: TrainingPlace.gym,
    description: 'Pull the bar to the upper chest, squeezing the shoulder blades.',
  ),
  Exercise(
    id: 'leg-press',
    name: 'Leg press',
    muscleGroup: MuscleGroup.legs,
    equipment: Equipment.machine,
    place: TrainingPlace.gym,
    description: 'Push the platform away without locking the knees.',
  ),
  Exercise(
    id: 'seated-row',
    name: 'Seated cable row',
    muscleGroup: MuscleGroup.back,
    equipment: Equipment.cable,
    place: TrainingPlace.gym,
    description: 'Pull the handle to the belly, chest up.',
  ),
  Exercise(
    id: 'overhead-press',
    name: 'Overhead press',
    muscleGroup: MuscleGroup.shoulders,
    equipment: Equipment.barbell,
    place: TrainingPlace.gym,
    description: 'Press the bar from the shoulders to overhead.',
  ),
  Exercise(
    id: 'treadmill',
    name: 'Treadmill run',
    muscleGroup: MuscleGroup.cardio,
    equipment: Equipment.machine,
    place: TrainingPlace.gym,
    tracking: TrackingType.duration,
    description: 'Steady run at a conversational pace.',
  ),

  // Gym & home
  Exercise(
    id: 'db-curl',
    name: 'Dumbbell curl',
    muscleGroup: MuscleGroup.arms,
    equipment: Equipment.dumbbell,
    place: TrainingPlace.both,
    description: 'Curl the dumbbells up, elbows close to the body.',
  ),
  Exercise(
    id: 'db-shoulder-press',
    name: 'Dumbbell shoulder press',
    muscleGroup: MuscleGroup.shoulders,
    equipment: Equipment.dumbbell,
    place: TrainingPlace.both,
    description: 'Press the dumbbells overhead from shoulder height.',
  ),
  Exercise(
    id: 'goblet-squat',
    name: 'Goblet squat',
    muscleGroup: MuscleGroup.legs,
    equipment: Equipment.kettlebell,
    place: TrainingPlace.both,
    description: 'Hold the weight at the chest and squat deep.',
  ),
  Exercise(
    id: 'kb-swing',
    name: 'Kettlebell swing',
    muscleGroup: MuscleGroup.fullBody,
    equipment: Equipment.kettlebell,
    place: TrainingPlace.both,
    description: 'Drive the hips forward to swing the bell to chest height.',
  ),

  // Home
  Exercise(
    id: 'push-up',
    name: 'Push-up',
    muscleGroup: MuscleGroup.chest,
    equipment: Equipment.none,
    place: TrainingPlace.home,
    tracking: TrackingType.reps,
    description: 'Body straight, lower the chest to the floor and push back.',
  ),
  Exercise(
    id: 'air-squat',
    name: 'Air squat',
    muscleGroup: MuscleGroup.legs,
    equipment: Equipment.none,
    place: TrainingPlace.home,
    tracking: TrackingType.reps,
    description: 'Feet shoulder width, squat below parallel and stand up.',
  ),
  Exercise(
    id: 'lunge',
    name: 'Walking lunge',
    muscleGroup: MuscleGroup.legs,
    equipment: Equipment.none,
    place: TrainingPlace.home,
    tracking: TrackingType.reps,
    description: 'Step forward and lower the back knee towards the floor.',
  ),
  Exercise(
    id: 'plank',
    name: 'Plank',
    muscleGroup: MuscleGroup.core,
    equipment: Equipment.none,
    place: TrainingPlace.home,
    tracking: TrackingType.duration,
    description: 'Hold a straight line from head to heels on the forearms.',
  ),
  Exercise(
    id: 'burpee',
    name: 'Burpee',
    muscleGroup: MuscleGroup.fullBody,
    equipment: Equipment.none,
    place: TrainingPlace.home,
    tracking: TrackingType.reps,
    description: 'Squat, jump the feet back, push-up, jump up.',
  ),
  Exercise(
    id: 'band-row',
    name: 'Band row',
    muscleGroup: MuscleGroup.back,
    equipment: Equipment.band,
    place: TrainingPlace.home,
    tracking: TrackingType.reps,
    description: 'Anchor the band and row the handles to the ribs.',
  ),
  Exercise(
    id: 'jumping-jacks',
    name: 'Jumping jacks',
    muscleGroup: MuscleGroup.cardio,
    equipment: Equipment.none,
    place: TrainingPlace.home,
    tracking: TrackingType.duration,
    description: 'Jump the feet out while raising the arms overhead.',
  ),
  Exercise(
    id: 'crunch',
    name: 'Crunch',
    muscleGroup: MuscleGroup.core,
    equipment: Equipment.none,
    place: TrainingPlace.home,
    tracking: TrackingType.reps,
    description: 'Lift the shoulders off the floor by contracting the abs.',
  ),
];

Exercise? exerciseById(String id) {
  for (final exercise in exerciseCatalog) {
    if (exercise.id == id) return exercise;
  }
  return null;
}
