import 'package:flutter/material.dart';

import 'app/app_info.dart';
import 'app/store_scope.dart';
import 'app/theme.dart';
import 'data/demo_data.dart';
import 'data/workout_store.dart';
import 'screens/home_shell.dart';

/// Everything lives in memory: the app starts with demo data each time.
void main() {
  runApp(MyApp(store: WorkoutStore(history: demoHistory())));
}

/// Root widget providing the workout store and the theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.store});

  final WorkoutStore store;

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      store: store,
      child: MaterialApp(
        title: AppInfo.name,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const HomeShell(),
      ),
    );
  }
}
