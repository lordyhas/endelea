import 'package:flutter/material.dart';

import 'app/settings_scope.dart';
import 'app/store_scope.dart';
import 'app/theme.dart';
import 'data/demo_data.dart';
import 'data/settings_store.dart';
import 'data/workout_store.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(
    MyApp(
      store: WorkoutStore(history: demoHistory()),
      settings: SettingsStore(),
    ),
  );
}

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
        child: MaterialApp(
          title: 'Endelea',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: const HomeShell(),
        ),
      ),
    );
  }
}
