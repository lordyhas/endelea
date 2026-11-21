import 'package:endelea/core/widgets/value_stepper.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers/pump_app.dart';

/// Lets the database work in real time, then rebuilds.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  // A small phone (360 × 640 dp) with text at 130 % (PLAN.md §11).
  setUp(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.textScaleFactorTestValue = 1.3;
    binding.platformDispatcher.views.first
      ..physicalSize = const Size(1080, 1920)
      ..devicePixelRatio = 3;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.clearTextScaleFactorTestValue();
    binding.platformDispatcher.views.first
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });

  testWidgets('session screen at 130 % text without overflow', (tester) async {
    await pumpEndeleaApp(
      tester,
      seed: (deps) async {
        final program = await deps.programs.createProgram('Push Pull Legs');
        final day = await deps.programs.addDay(program, 'Jour A — Push');
        await deps.programs.addExercises(
          day,
          [
            builtInExerciseId('overhead_triceps_extension'),
            builtInExerciseId('bench_press'),
          ],
          defaults: const ExerciseTargets(
            sets: 4,
            repsMin: 8,
            repsMax: 10,
            weightKg: 102.5,
            restSeconds: 90,
          ),
        );
      },
    );
    await settle(tester);
    expect(tester.takeException(), isNull, reason: 'home');

    await tester.tap(find.text('Séance'));
    await settle(tester);
    await tester.tap(find.text('Démarrer'));
    await settle(tester);
    expect(tester.takeException(), isNull, reason: 'session');

    await tester.tap(find.text('Valider la série'));
    await settle(tester);
    expect(tester.takeException(), isNull, reason: 'rest');

    // Steppers are announced with their value.
    await tester.dragUntilVisible(
      find.byType(WeightStepper),
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    await settle(tester);
    expect(tester.takeException(), isNull, reason: 'set editor');
    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp('^Charge, 102,5 kilos')), findsWidgets);
    handle.dispose();

    await tester.tap(find.text('Accueil'));
    await settle(tester);
    expect(tester.takeException(), isNull, reason: 'home with mini player');
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
  });
}
