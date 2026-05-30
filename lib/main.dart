import 'package:flutter/material.dart';

import 'app/app_info.dart';
import 'app/backup_scope.dart';
import 'app/exercise_scope.dart';
import 'app/settings_scope.dart';
import 'app/store_scope.dart';
import 'app/template_scope.dart';
import 'app/theme.dart';
import 'data/app_loader.dart';
import 'data/app_repository.dart';
import 'data/auto_save.dart';
import 'data/exercise_store.dart';
import 'data/settings_store.dart';
import 'data/storage/file_storage.dart';
import 'data/storage/key_value_storage.dart';
import 'data/sync/backup_service.dart';
import 'data/sync/google_drive_sync_provider.dart';
import 'data/template_store.dart';
import 'data/workout_store.dart';
import 'screens/home_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = AppRepository(await _openStorage());
  final stores = await loadStores(repository);
  final autoSave = AutoSave(
    repository: repository,
    workouts: stores.workouts,
    settings: stores.settings,
    exercises: stores.exercises,
    templates: stores.templates,
  );
  final backup = BackupService(
    provider: GoogleDriveSyncProvider(),
    workouts: stores.workouts,
    settings: stores.settings,
    exercises: stores.exercises,
    templates: stores.templates,
  );
  // The app can be killed while in the background, so save right away.
  AppLifecycleListener(onHide: autoSave.flush);
  runApp(
    MyApp(
      store: stores.workouts,
      settings: stores.settings,
      exercises: stores.exercises,
      templates: stores.templates,
      backup: backup,
    ),
  );
}

/// Files in the documents folder, or memory where there is no file system.
Future<KeyValueStorage> _openStorage() async {
  try {
    return await FileStorage.inDocuments();
  } catch (error) {
    debugPrint('Data will not be saved: $error');
    return MemoryStorage();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.store,
    required this.settings,
    required this.exercises,
    required this.templates,
    this.backup,
  });

  final WorkoutStore store;
  final SettingsStore settings;
  final ExerciseStore exercises;
  final TemplateStore templates;
  final BackupService? backup;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      settings: settings,
      child: ExerciseScope(
        exercises: exercises,
        child: TemplateScope(
          templates: templates,
          child: StoreScope(
            store: store,
            child: BackupScope(
              backup: backup,
              child: ListenableBuilder(
                listenable: settings,
                builder: (context, _) => MaterialApp(
                  title: AppInfo.name,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light(),
                  darkTheme: AppTheme.dark(),
                  themeMode: settings.settings.themeMode,
                  home: const HomeShell(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
