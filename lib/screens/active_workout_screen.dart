import 'package:flutter/material.dart';

import '../app/store_scope.dart';
import '../widgets/exercise_tile.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = StoreScope.of(context).active;
    if (workout == null) {
      return const Scaffold(body: Center(child: Text('No active workout')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(workout.name)),
      body: workout.exercises.isEmpty
          ? const Center(child: Text('Add your first exercise'))
          : ListView(
              children: [
                for (final entry in workout.exercises)
                  ExerciseTile(exercise: entry.exercise),
              ],
            ),
    );
  }
}
