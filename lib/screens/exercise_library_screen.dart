import 'package:flutter/material.dart';

import '../data/exercise_catalog.dart';
import '../widgets/exercise_tile.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const exercises = exerciseCatalog;
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) => ExerciseTile(exercise: exercises[index]),
      ),
    );
  }
}
