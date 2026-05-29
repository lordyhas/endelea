import 'dart:convert';

import 'package:endelea/data/exercise_catalog.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/settings.dart';
import 'package:endelea/models/workout.dart';
import 'package:endelea/models/workout_template.dart';
import 'package:flutter/material.dart' show ThemeMode;
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

  test('routine round trips its exercises and set counts', () {
    final template = WorkoutTemplate(
      id: 't1',
      name: 'Legs',
      place: TrainingPlace.gym,
      exercises: [
        TemplateExercise(exercise: exerciseById('back-squat')!, sets: 5),
        TemplateExercise(exercise: exerciseById('plank')!),
      ],
    );

    final copy = WorkoutTemplate.fromJson(
      _roundTrip(template.toJson()),
      exerciseById,
    );

    expect(copy.name, 'Legs');
    expect(copy.place, TrainingPlace.gym);
    expect(copy.exercises.map((e) => e.sets), [5, 3]);
  });

  test('custom exercise round trips', () {
    const exercise = Exercise(
      id: 'custom-1',
      name: 'Sled push',
      muscleGroup: MuscleGroup.legs,
      equipment: Equipment.machine,
      place: TrainingPlace.gym,
      tracking: TrackingType.duration,
      description: 'Push hard',
      custom: true,
    );

    final copy = Exercise.fromJson(_roundTrip(exercise.toJson()));

    expect(copy, exercise);
    expect(copy.name, 'Sled push');
    expect(copy.muscleGroup, MuscleGroup.legs);
    expect(copy.equipment, Equipment.machine);
    expect(copy.tracking, TrackingType.duration);
    expect(copy.description, 'Push hard');
    expect(copy.custom, isTrue);
  });

  test('settings round trip and fall back to defaults', () {
    const settings = AppSettings(
      weightUnit: WeightUnit.lb,
      restDuration: Duration(seconds: 120),
      themeMode: ThemeMode.dark,
    );

    final copy = AppSettings.fromJson(_roundTrip(settings.toJson()));
    final fallback = AppSettings.fromJson({'weightUnit': 'stone'});

    expect(copy.weightUnit, WeightUnit.lb);
    expect(copy.restDuration, const Duration(seconds: 120));
    expect(copy.themeMode, ThemeMode.dark);
    expect(fallback.weightUnit, WeightUnit.kg);
    expect(fallback.restDuration, const Duration(seconds: 90));
  });
}
