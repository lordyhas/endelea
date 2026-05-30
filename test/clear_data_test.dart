import 'package:endelea/data/demo_data.dart';
import 'package:endelea/data/exercise_store.dart';
import 'package:endelea/data/settings_store.dart';
import 'package:endelea/data/template_store.dart';
import 'package:endelea/data/workout_store.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stores can be cleared', () {
    final workouts = WorkoutStore(history: demoHistory())
      ..start(name: 'Now', place: TrainingPlace.home);
    final templates = TemplateStore(templates: demoTemplates());
    final exercises = ExerciseStore()
      ..add(
        name: 'Sled push',
        muscleGroup: MuscleGroup.legs,
        equipment: Equipment.machine,
        place: TrainingPlace.gym,
        tracking: TrackingType.duration,
      );
    final settings = SettingsStore(
      const AppSettings(weightUnit: WeightUnit.lb),
    );

    workouts.clear();
    templates.clear();
    exercises.clear();
    settings.reset();

    expect(workouts.history, isEmpty);
    expect(workouts.active, isNull);
    expect(templates.templates, isEmpty);
    expect(exercises.custom, isEmpty);
    expect(exercises.all, isNotEmpty);
    expect(settings.settings.weightUnit, WeightUnit.kg);
  });
}
