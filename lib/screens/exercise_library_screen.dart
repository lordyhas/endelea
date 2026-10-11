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
  String _query = '';
  MuscleGroup? _muscleGroup;

  List<Exercise> _filter(List<Exercise> all) {
    final query = _query.trim().toLowerCase();
    return all
        .where((e) => e.place.matches(_place))
        .where((e) => _muscleGroup == null || e.muscleGroup == _muscleGroup)
        .where(
          (e) =>
              query.isEmpty ||
              e.name.toLowerCase().contains(query) ||
              e.muscleGroup.label.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filter(exerciseCatalog);
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or muscle',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
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
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final group in MuscleGroup.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(group.label),
                      selected: _muscleGroup == group,
                      onSelected: (selected) => setState(
                        () => _muscleGroup = selected ? group : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: exercises.isEmpty
                ? const Center(child: Text('No exercise found'))
                : ListView.builder(
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
