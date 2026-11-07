import 'package:endelea/core/widgets/rest_timer.dart';
import 'package:endelea/core/widgets/set_row.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:endelea/features/session/view/mini_player.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// The session screen has running clocks: settle with short pumps.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    // Let the database work in real time, then rebuild.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('a guided session from start to finish', (tester) async {
    final deps = await pumpEndeleaApp(tester);
    await tester.runAsync(() async {
      final program = await deps.programs.createProgram('PPL');
      final day = await deps.programs.addDay(program, 'Push');
      await deps.programs.addExercises(
        day,
        [builtInExerciseId('bench_press'), builtInExerciseId('back_squat')],
        defaults: const ExerciseTargets(
          sets: 1,
          repsMin: 8,
          repsMax: 10,
          weightKg: 60,
          restSeconds: 90,
        ),
      );
    });

    await tester.tap(find.text('Séance'));
    await settle(tester);
    expect(find.text('PROCHAINE SÉANCE'), findsOneWidget);
    await tester.tap(find.text('Démarrer'));
    await settle(tester);

    // First exercise, set pre-filled: one tap validates.
    expect(find.text('Développé couché'), findsOneWidget);
    expect(find.text('Exercice 1 sur 2 · cible 1 × 8–10'), findsOneWidget);
    expect(find.text('60'), findsWidgets);
    await tester.tap(find.text('Valider la série'));
    await settle(tester);

    expect(find.byType(RestTimerBar), findsOneWidget);
    expect(find.text('1:30'), findsOneWidget);
    expect(tester.widget<SetRow>(find.byType(SetRow)).state, SetRowState.done);
    await tester.tap(find.text('Passer le repos'));
    await settle(tester);

    expect(find.byType(RestTimerBar), findsNothing);
    await tester.tap(find.text('Exercice suivant'));
    await settle(tester);
    expect(find.text('Squat'), findsOneWidget);

    // The mini player shows on other tabs.
    await tester.tap(find.text('Accueil'));
    await settle(tester);
    expect(find.byType(MiniPlayer), findsOneWidget);
    expect(find.text('Reprendre la séance'), findsOneWidget);
    await tester.tap(find.text('Reprendre la séance'));
    await settle(tester);

    await tester.tap(find.text('Valider la série'));
    await settle(tester);
    await tester.tap(find.text('Terminer la séance'));
    await settle(tester);
    expect(find.text('Résumé de la séance'), findsOneWidget);
    expect(find.text('2'), findsWidgets);

    await tester.tap(find.text('Terminer'));
    await settle(tester);
    final history = await tester.runAsync(deps.sessions.getHistory);
    expect(history!.single.exercises, hasLength(2));
  });
}
