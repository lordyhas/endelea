import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:endelea/data/settings_store.dart';
import 'package:endelea/data/workout_store.dart';
import 'package:endelea/main.dart';

void main() {
  testWidgets('App starts on the today tab', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(store: WorkoutStore(), settings: SettingsStore()),
    );

    expect(find.text('Endelea'), findsOneWidget);
    expect(find.text('Start workout'), findsOneWidget);
  });

  testWidgets('Starting a workout opens the active workout screen', (
    WidgetTester tester,
  ) async {
    final store = WorkoutStore();
    await tester.pumpWidget(MyApp(store: store, settings: SettingsStore()));

    await tester.tap(find.text('Start workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(store.active, isNotNull);
    expect(store.active!.name, 'Home workout');
    expect(find.text('Add your first exercise'), findsOneWidget);
  });

  testWidgets('Exercises tab can filter home exercises', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MyApp(store: WorkoutStore(), settings: SettingsStore()),
    );

    await tester.tap(find.byIcon(Icons.fitness_center_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Bench press'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Bench press'), findsNothing);
    expect(find.text('Push-up'), findsOneWidget);
  });
}
