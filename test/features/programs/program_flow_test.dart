import 'package:endelea/core/widgets/cards.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('create a program, a day and its exercises by tapping', (
    tester,
  ) async {
    final deps = await pumpEndeleaApp(tester);

    await tester.tap(find.text('Programmes'));
    await tester.pumpAndSettle();
    expect(find.text('Crée ton premier programme'), findsOneWidget);

    // New program.
    await tester.tap(find.text('Nouveau programme'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'PPL');
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();
    expect(find.text('Ajoute un premier jour'), findsOneWidget);

    // First day, default name.
    await tester.tap(find.text('Ajouter un jour'));
    await tester.pumpAndSettle();
    expect(find.text('Jour A'), findsOneWidget);
    await tester.tap(find.text('Créer'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun exercice'), findsOneWidget);

    // Pick five exercises.
    await tester.tap(find.text('Ajouter un exercice'));
    await tester.pumpAndSettle();
    final tiles = find.byType(ExerciseTile);
    for (var i = 0; i < 5; i++) {
      await tester.tap(tiles.at(i));
      await tester.pump();
    }
    await tester.tap(find.text('Ajouter (5)'));
    await tester.pumpAndSettle();
    expect(find.byType(ExerciseTile), findsNWidgets(5));
    expect(find.textContaining('repos 1:30'), findsNWidgets(5));

    final programs = await tester.runAsync(deps.programs.getSummaries);
    expect(programs!.single.program.name, 'PPL');
    expect(programs.single.program.isActive, isTrue);
    expect(programs.single.dayCount, 1);
  });
}
