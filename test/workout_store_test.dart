import 'package:flutter_test/flutter_test.dart';

import 'package:endelea/data/exercise_catalog.dart';
import 'package:endelea/data/workout_store.dart';
import 'package:endelea/models/exercise.dart';

void main() {
  group('WorkoutStore', () {
    test('starts a workout and adds exercises', () {
      final store = WorkoutStore();
      store.start(name: 'Test', place: TrainingPlace.gym);
      store.addExercise(exerciseById('bench-press')!);

      expect(store.active, isNotNull);
      expect(store.active!.exercises, hasLength(1));
      expect(store.active!.exercises.first.sets, hasLength(1));
    });

    test('finish keeps only completed sets and saves to history', () {
      final store = WorkoutStore();
      store.start(name: 'Test', place: TrainingPlace.gym);
      store.addExercise(exerciseById('bench-press')!);
      store.addExercise(exerciseById('push-up')!);
      final bench = store.active!.exercises.first;
      bench.sets.first
        ..weight = 50
        ..reps = 10
        ..done = true;

      final saved = store.finish();

      expect(store.active, isNull);
      expect(store.history, [saved]);
      expect(saved!.exercises, hasLength(1));
      expect(saved.volume, 500);
      expect(saved.isFinished, isTrue);
    });

    test('discard drops the active workout', () {
      final store = WorkoutStore();
      store.start(name: 'Test', place: TrainingPlace.home);
      store.discard();

      expect(store.active, isNull);
      expect(store.history, isEmpty);
    });
  });
}
