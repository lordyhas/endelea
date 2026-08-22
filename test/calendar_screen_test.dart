import 'package:endelea/app/settings_scope.dart';
import 'package:endelea/app/store_scope.dart';
import 'package:endelea/data/settings_store.dart';
import 'package:endelea/data/workout_store.dart';
import 'package:endelea/models/exercise.dart';
import 'package:endelea/models/workout.dart';
import 'package:endelea/screens/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('browses months and shows the workouts of a day', (tester) async {
    // Phone sized screen, so the whole month fits.
    tester.view
      ..physicalSize = const Size(1080, 2340)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final store = WorkoutStore(
      history: [
        Workout(
          id: 'w1',
          name: 'Leg day',
          place: TrainingPlace.gym,
          startedAt: DateTime(2026, 7, 14, 18),
          finishedAt: DateTime(2026, 7, 14, 19),
        ),
      ],
    );
    await tester.pumpWidget(
      SettingsScope(
        settings: SettingsStore(),
        child: StoreScope(
          store: store,
          child: MaterialApp(home: CalendarScreen(now: DateTime(2026, 8, 22))),
        ),
      ),
    );

    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('0 workouts on 0 days'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pump();
    expect(find.text('July 2026'), findsOneWidget);
    expect(find.text('1 workout on 1 day'), findsOneWidget);

    await tester.tap(find.text('14'));
    await tester.pump();
    expect(find.text('Tue 14 Jul'), findsWidgets);
    expect(find.text('Leg day'), findsOneWidget);
  });
}
