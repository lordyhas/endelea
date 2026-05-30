import 'package:endelea/data/demo_data.dart';
import 'package:endelea/data/exercise_store.dart';
import 'package:endelea/data/settings_store.dart';
import 'package:endelea/data/sync/backup_service.dart';
import 'package:endelea/data/sync/memory_sync_provider.dart';
import 'package:endelea/data/template_store.dart';
import 'package:endelea/data/workout_store.dart';
import 'package:endelea/main.dart';
import 'package:endelea/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('backs up from the settings screen', (tester) async {
    final provider = MemorySyncProvider();
    final store = WorkoutStore(history: demoHistory());
    final settings = SettingsStore();
    final exercises = ExerciseStore();
    final templates = TemplateStore();
    await tester.pumpWidget(
      MyApp(
        store: store,
        settings: settings,
        exercises: exercises,
        templates: templates,
        backup: BackupService(
          provider: provider,
          workouts: store,
          settings: settings,
          exercises: exercises,
          templates: templates,
        ),
      ),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Not signed in'), findsOneWidget);
    expect(find.text('Never backed up'), findsOneWidget);

    await tester.tap(find.text('Back up now'));
    await tester.pumpAndSettle();

    expect(find.text(provider.accountName), findsOneWidget);
    expect(find.text('Backed up to Memory'), findsOneWidget);
    expect(provider.files, contains(BackupService.fileName));
    expect(settings.settings.lastBackupAt, isNotNull);
  });
}
