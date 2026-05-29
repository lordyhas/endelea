import 'dart:convert';

import 'package:endelea/data/exercise_catalog.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/workout.dart';
import 'package:flutter_test/flutter_test.dart';

/// Encodes and decodes like the files on disk do.
Map<String, dynamic> _roundTrip(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

void main() {
  group('Workout json', () {
    final workout = Workout(
      id: 'w1',
      name: 'Push day',
      place: TrainingPlace.gym,
      startedAt: DateTime(2026, 5, 29, 7, 30),
      finishedAt: DateTime(2026, 5, 29, 8, 15),
      notes: 'Felt strong',
      exercises: [
        WorkoutExercise(
          exercise: exerciseById('bench-press')!,
          sets: [
            WorkoutSet(weight: 60, reps: 8, done: true),
            WorkoutSet(weight: 62.5, reps: 6, done: true),
          ],
        ),
        WorkoutExercise(
          exercise: exerciseById('plank')!,
          sets: [WorkoutSet(seconds: 60, done: true)],
        ),
      ],
    );

    test('round trips every field', () {
      final copy = Workout.fromJson(_roundTrip(workout.toJson()), exerciseById);

      expect(copy.id, 'w1');
      expect(copy.name, 'Push day');
      expect(copy.place, TrainingPlace.gym);
      expect(copy.startedAt, workout.startedAt);
      expect(copy.finishedAt, workout.finishedAt);
      expect(copy.notes, 'Felt strong');
      expect(copy.exercises, hasLength(2));
      expect(copy.exercises.first.sets[1].weight, 62.5);
      expect(copy.exercises.last.sets.single.seconds, 60);
      expect(copy.volume, workout.volume);
    });

    test('keeps an unfinished workout unfinished', () {
      final active = Workout(
        id: 'w2',
        name: 'Now',
        place: TrainingPlace.home,
        startedAt: DateTime(2026, 5, 29),
      );

      final copy = Workout.fromJson(_roundTrip(active.toJson()), exerciseById);

      expect(copy.isFinished, isFalse);
    });

    test('drops exercises that no longer exist', () {
      final copy = Workout.fromJson(
        _roundTrip(workout.toJson()),
        (id) => id == 'plank' ? null : exerciseById(id),
      );

      expect(copy.exercises.single.exercise.id, 'bench-press');
    });
  });
}
