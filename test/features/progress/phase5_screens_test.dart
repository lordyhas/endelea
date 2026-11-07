import 'package:endelea/bootstrap.dart';
import 'package:endelea/core/widgets/charts.dart';
import 'package:endelea/core/widgets/set_row.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

/// Lets the database work in real time, then rebuilds.
/// Removes the app so no stream or timer outlives the test.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await settle(tester);
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Two finished bench sessions, the second heavier.
Future<void> seedHistory(AppDependencies deps) async {
  final clock = deps.clock as FakeClock;
  final bench = builtInExerciseId('bench_press');
  {
    for (final (daysAgo, weight) in [(8, 60.0), (1, 65.0)]) {
      clock.time = DateTime(2026, 11, 20, 18).subtract(Duration(days: daysAgo));
      final id = await deps.sessions.start(
        name: 'Push',
        plan: [
          PlannedSessionExercise(
            exerciseId: bench,
            restSeconds: 90,
            sets: List.filled(2, SetValues(reps: 8, weightKg: weight)),
          ),
        ],
      );
      final details = await deps.sessions.getActive();
      for (final set in details!.exercises.single.sets) {
        await deps.sessions.completeSet(
          set.id,
          SetValues(reps: 8, weightKg: weight),
          sessionId: id,
        );
      }
      clock.advance(const Duration(minutes: 40));
      await deps.sessions.finish(id);
    }
    clock.time = DateTime(2026, 11, 20, 19);
  }
}

void main() {
  testWidgets('history list, detail and correction', (tester) async {
    await pumpEndeleaApp(tester, seed: seedHistory);

    await tester.tap(find.text('Historique'));
    await settle(tester);
    expect(find.text('Push'), findsNWidgets(2));
    expect(find.textContaining('40 min'), findsNWidgets(2));

    await tester.tap(find.text('Push').first);
    await settle(tester);
    expect(find.byType(SetRow), findsNWidgets(2));
    expect(find.text('65'), findsNWidgets(2));

    // Correct the first set.
    await tester.tap(find.byType(SetRow).first);
    await settle(tester);
    await tester.tap(
      find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byIcon(PhosphorIconsRegular.plus),
          )
          .first,
    );
    await settle(tester);
    await tester.tap(find.text('Enregistrer'));
    await settle(tester);
    expect(find.text('67,5'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('progress screen with chart and exercise detail', (tester) async {
    await pumpEndeleaApp(tester, seed: seedHistory);

    await tester.tap(find.text('Progrès'));
    await settle(tester);
    expect(find.byType(WeeklyBarChart), findsOneWidget);
    expect(find.text('Développé couché'), findsOneWidget);
    expect(find.text('2 séances'), findsOneWidget);

    await tester.tap(find.text('Développé couché'));
    await settle(tester);
    expect(find.byType(ProgressLineChart), findsOneWidget);
    expect(find.text('65 kg'), findsWidgets);
    expect(tester.takeException(), isNull);

    // Switch the curve.
    await tester.tap(find.text('Volume'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('home shows the week and the latest records', (tester) async {
    await pumpEndeleaApp(
      tester,
      seed: (deps) async {
        await deps.programs.createProgram('PPL');
        await seedHistory(deps);
      },
    );
    await settle(tester);

    expect(find.text('Séances cette semaine'), findsOneWidget);
    expect(find.text('DERNIERS RECORDS'), findsOneWidget);
    expect(find.text('Record'), findsWidgets);
    await unmount(tester);
  });

  testWidgets('body weight entry', (tester) async {
    final deps = await pumpEndeleaApp(tester);
    await tester.tap(find.text('Progrès'));
    await settle(tester);
    await tester.tap(find.text('Poids corporel').last);
    await settle(tester);
    expect(find.text('Aucune mesure'), findsOneWidget);

    await tester.tap(find.text('Ajouter une mesure').last);
    await settle(tester);
    await tester.tap(find.text('Enregistrer'));
    await settle(tester);
    expect(find.text('75 kg'), findsOneWidget);
    final saved = await tester.runAsync(() => deps.body.watchAll().first);
    expect(saved!.single.bodyWeightKg, 75);
    await unmount(tester);
  });
}
