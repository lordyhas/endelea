import 'package:endelea/data/app_repository.dart';
import 'package:endelea/data/exercise_catalog.dart';
import 'package:endelea/data/storage/key_value_storage.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/settings.dart';
import 'package:endelea/models/workout.dart';
import 'package:endelea/models/workout_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppRepository repository;

  setUp(() => repository = AppRepository(MemoryStorage()));

  test('returns null when nothing was saved yet', () async {
    expect(await repository.loadSettings(), isNull);
    expect(await repository.loadCustomExercises(), isNull);
    expect(await repository.loadRoutines(exerciseById), isNull);
    expect(await repository.loadHistory(exerciseById), isNull);
    expect(await repository.loadActive(exerciseById), isNull);
  });

  test('saves and loads every kind of data', () async {
    const custom = Exercise(
      id: 'custom-1',
      name: 'Sled push',
      muscleGroup: MuscleGroup.legs,
      equipment: Equipment.machine,
      place: TrainingPlace.gym,
      custom: true,
    );
    Exercise? lookup(String id) => id == custom.id ? custom : exerciseById(id);
    final workout = Workout(
      id: 'w1',
      name: 'Legs',
      place: TrainingPlace.gym,
      startedAt: DateTime(2026, 5, 29, 7),
      finishedAt: DateTime(2026, 5, 29, 8),
      exercises: [
        WorkoutExercise(
          exercise: custom,
          sets: [WorkoutSet(weight: 100, reps: 5, done: true)],
        ),
      ],
    );

    await repository.saveSettings(const AppSettings(weightUnit: WeightUnit.lb));
    await repository.saveCustomExercises([custom]);
    await repository.saveRoutines([
      WorkoutTemplate.fromWorkout(workout, id: 't1'),
    ]);
    await repository.saveHistory([workout]);

    expect((await repository.loadSettings())!.weightUnit, WeightUnit.lb);
    expect(await repository.loadCustomExercises(), [custom]);
    final routines = await repository.loadRoutines(lookup);
    expect(routines!.single.exercises.single.exercise, custom);
    final history = await repository.loadHistory(lookup);
    expect(history!.single.volume, 500);
  });

  test('forgets the active workout when it ends', () async {
    final active = Workout(
      id: 'w2',
      name: 'Now',
      place: TrainingPlace.home,
      startedAt: DateTime(2026, 5, 29),
    );

    await repository.saveActive(active);
    expect((await repository.loadActive(exerciseById))!.id, 'w2');

    await repository.saveActive(null);
    expect(await repository.loadActive(exerciseById), isNull);
  });

  test('keeps unreadable data aside and reads it as missing', () async {
    final storage = MemoryStorage({
      AppRepository.historyKey: '[{"id": 1',
      AppRepository.settingsKey: '"not settings"',
    });
    final broken = AppRepository(storage);

    expect(await broken.loadHistory(exerciseById), isNull);
    expect(await broken.loadSettings(), isNull);
    expect(storage.values['history-unreadable'], '[{"id": 1');
    expect(storage.values['settings-unreadable'], '"not settings"');
  });
}
