import 'dart:convert';

import 'package:endelea/data/demo_data.dart';
import 'package:endelea/data/exercise_store.dart';
import 'package:endelea/data/export.dart';
import 'package:endelea/data/settings_store.dart';
import 'package:endelea/data/template_store.dart';
import 'package:endelea/data/workout_store.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exports every kind of data as json', () {
    final text = exportData(
      workouts: WorkoutStore(history: demoHistory()),
      settings: SettingsStore(),
      exercises: ExerciseStore(),
      templates: TemplateStore(templates: demoTemplates()),
      now: DateTime(2026, 5, 29, 21),
    );

    final json = jsonDecode(text) as Map<String, dynamic>;
    expect(json['app'], 'Endelea');
    expect(json['exportedAt'], '2026-05-29T21:00:00.000');
    expect(json['settings'], containsPair('weightUnit', 'kg'));
    expect(json['exercises'], isEmpty);
    expect(json['routines'], hasLength(demoTemplates().length));
    expect(json['history'], hasLength(demoHistory().length));
  });

  test('reads back its own export, custom exercises included', () {
    final exercises = ExerciseStore();
    final custom = exercises.add(
      name: 'Sled push',
      muscleGroup: MuscleGroup.legs,
      equipment: Equipment.machine,
      place: TrainingPlace.gym,
      tracking: TrackingType.duration,
    );
    final workouts = WorkoutStore(history: demoHistory())
      ..start(name: 'Sled', place: TrainingPlace.gym)
      ..addExercise(custom);
    workouts.active!.exercises.single.sets.single
      ..seconds = 30
      ..done = true;
    workouts.finish();

    final data = parseExport(
      exportData(
        workouts: workouts,
        settings: SettingsStore(const AppSettings(weightUnit: WeightUnit.lb)),
        exercises: exercises,
        templates: TemplateStore(templates: demoTemplates()),
      ),
    );

    expect(data.settings.weightUnit, WeightUnit.lb);
    expect(data.exercises, [custom]);
    expect(data.routines, hasLength(demoTemplates().length));
    expect(data.history, hasLength(demoHistory().length + 1));
    expect(data.history.first.exercises.single.exercise, custom);
  });

  test('rejects text that is not an export', () {
    expect(() => parseExport('hello'), throwsFormatException);
    expect(() => parseExport('{"app": "Other"}'), throwsFormatException);
    expect(() => parseExport('{"app": "Endelea"}'), throwsFormatException);
  });
}
