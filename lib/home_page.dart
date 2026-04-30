import 'package:flutter/material.dart';

import 'app/store_scope.dart';
import 'screens/active_workout_screen.dart';
import 'screens/start_workout_sheet.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final active = StoreScope.of(context).active;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
        title: Text(title ?? 'Endelea'),
      ),
      body: const Center(child: Text('Sport Gymnasium Tracking')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (active != null) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ActiveWorkoutScreen(),
              ),
            );
          } else {
            StartWorkoutSheet.show(context);
          }
        },
        icon: Icon(active != null ? Icons.timer_outlined : Icons.play_arrow),
        label: Text(active != null ? 'Resume workout' : 'Start workout'),
      ),
    );
  }
}
