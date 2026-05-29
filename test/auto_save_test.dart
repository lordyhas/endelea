import 'package:endelea/data/app_repository.dart';
import 'package:endelea/data/auto_save.dart';
import 'package:endelea/data/exercise_catalog.dart';
import 'package:endelea/data/exercise_store.dart';
import 'package:endelea/data/settings_store.dart';
import 'package:endelea/data/storage/key_value_storage.dart';
import 'package:endelea/data/template_store.dart';
import 'package:endelea/data/workout_store.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MemoryStorage storage;
  late WorkoutStore workouts;
  late SettingsStore settings;
  late AutoSave autoSave;

  setUp(() {
    storage = MemoryStorage();
    workouts = WorkoutStore();
    settings = SettingsStore();
    autoSave = AutoSave(
      repository: AppRepository(storage),
      workouts: workouts,
      settings: settings,
      exercises: ExerciseStore(),
      templates: TemplateStore(),
      delay: const Duration(milliseconds: 100),
    );
  });

  tearDown(() => autoSave.dispose());

  test('waits for the delay before writing', () async {
    settings.weightUnit = WeightUnit.lb;
    expect(storage.values, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(storage.values.keys, contains(AppRepository.settingsKey));
  });

  test('flush saves the active workout and the history', () async {
    workouts.start(name: 'Test', place: TrainingPlace.gym);
    workouts.addExercise(exerciseById('bench-press')!);
    await autoSave.flush();
    expect(storage.values.keys, contains(AppRepository.activeKey));

    workouts.active!.exercises.first.sets.first.done = true;
    workouts.finish();
    await autoSave.flush();

    final repository = AppRepository(storage);
    expect(await repository.loadActive(exerciseById), isNull);
    expect(await repository.loadHistory(exerciseById), hasLength(1));
  });
}
