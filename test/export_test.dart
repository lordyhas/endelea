import 'dart:convert';

import 'package:endelea/data/demo_data.dart';
import 'package:endelea/data/exercise_store.dart';
import 'package:endelea/data/export.dart';
import 'package:endelea/data/settings_store.dart';
import 'package:endelea/data/template_store.dart';
import 'package:endelea/data/workout_store.dart';
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
}
