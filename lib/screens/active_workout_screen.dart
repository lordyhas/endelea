import 'package:flutter/material.dart';

import '../app/store_scope.dart';
import '../models/exercise.dart';
import '../widgets/exercise_tile.dart';
import 'exercise_picker_screen.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final workout = store.active;
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
                const SizedBox(height: 88),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final exercise = await Navigator.of(context).push<Exercise>(
            MaterialPageRoute(
              builder: (_) => ExercisePickerScreen(place: workout.place),
            ),
          );
          if (exercise != null) store.addExercise(exercise);
        },
        icon: const Icon(Icons.add),
        label: const Text('Exercise'),
      ),
    );
  }
}
