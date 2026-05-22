import 'package:endelea/data/exercise_catalog.dart';
import 'package:endelea/data/exercise_store.dart';
import 'package:endelea/models/exercise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Exercise addPullUp(ExerciseStore store) => store.add(
    name: 'Pull-up',
    muscleGroup: MuscleGroup.back,
    equipment: Equipment.none,
    place: TrainingPlace.both,
    tracking: TrackingType.reps,
  );

  test('lists built-in exercises sorted by name', () {
    final store = ExerciseStore();
    final names = store.all.map((e) => e.name.toLowerCase()).toList();

    expect(store.all, hasLength(exerciseCatalog.length));
    expect(names, [...names]..sort());
  });

  test('adds a custom exercise and finds it by id', () {
    final store = ExerciseStore();
    var notified = 0;
    store.addListener(() => notified++);

    final pullUp = addPullUp(store);

    expect(notified, 1);
    expect(pullUp.custom, isTrue);
    expect(store.custom, [pullUp]);
    expect(store.all, contains(pullUp));
    expect(store.byId(pullUp.id), pullUp);
    expect(store.byId('bench-press')?.name, 'Bench press');
  });

  test('removes custom exercises but never built-in ones', () {
    final store = ExerciseStore();
    final pullUp = addPullUp(store);

    store.remove(exerciseById('bench-press')!);
    store.remove(pullUp);

    expect(store.custom, isEmpty);
    expect(store.all, hasLength(exerciseCatalog.length));
  });
}
