import 'package:endelea/data/exercise_catalog.dart';
import 'package:endelea/data/exercise_store.dart';
import 'package:endelea/data/settings_store.dart';
import 'package:endelea/data/template_store.dart';
import 'package:endelea/data/workout_store.dart';
import 'package:endelea/main.dart';
import 'package:endelea/models/exercise.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('moves an exercise down from its card menu', (tester) async {
    final store = WorkoutStore()
      ..start(name: 'Push', place: TrainingPlace.gym)
      ..addExercise(exerciseById('bench-press')!)
      ..addExercise(exerciseById('push-up')!);
    await tester.pumpWidget(
      MyApp(
        store: store,
        settings: SettingsStore(),
        exercises: ExerciseStore(),
        templates: TemplateStore(),
      ),
    );
    await tester.tap(find.text('Resume workout'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Exercise options').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move down'));
    await tester.pumpAndSettle();

    expect(
      [for (final e in store.active!.exercises) e.exercise.id],
      ['push-up', 'bench-press'],
    );
  });
}
