import 'package:flutter/material.dart';

import '../data/exercise_catalog.dart';
import '../models/exercise.dart';
import '../widgets/exercise_tile.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  TrainingPlace _place = TrainingPlace.both;

  List<Exercise> get _filtered =>
      exerciseCatalog.where((e) => e.place.matches(_place)).toList();

  @override
  Widget build(BuildContext context) {
    final exercises = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<TrainingPlace>(
              segments: const [
                ButtonSegment(value: TrainingPlace.both, label: Text('All')),
                ButtonSegment(
                  value: TrainingPlace.gym,
                  label: Text('Gym'),
                  icon: Icon(Icons.fitness_center),
                ),
                ButtonSegment(
                  value: TrainingPlace.home,
                  label: Text('Home'),
                  icon: Icon(Icons.house_outlined),
                ),
              ],
              selected: {_place},
              onSelectionChanged: (selection) =>
                  setState(() => _place = selection.first),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) =>
                  ExerciseTile(exercise: exercises[index]),
            ),
          ),
        ],
      ),
    );
  }
}
