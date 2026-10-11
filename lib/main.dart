import 'package:flutter/material.dart';

import 'app/app_info.dart';
import 'app/settings_scope.dart';
import 'app/store_scope.dart';
import 'app/theme.dart';
import 'data/demo_data.dart';
import 'data/settings_store.dart';
import 'data/workout_store.dart';
import 'screens/home_shell.dart';

/// Everything lives in memory: the app starts with demo data each time.
void main() {
  runApp(
    MyApp(
      store: WorkoutStore(history: demoHistory()),
      settings: SettingsStore(),
    ),
  );
}

/// Root widget providing the stores and the theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.store, required this.settings});

  final WorkoutStore store;
  final SettingsStore settings;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      settings: settings,
      child: StoreScope(
        store: store,
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
    );
  }
}
