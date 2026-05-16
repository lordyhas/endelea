import 'package:flutter/material.dart';

import '../app/exercise_scope.dart';
import '../models/exercise.dart';
import '../widgets/exercise_tile.dart';

/// Lets the user pick an exercise suited to where they train.
class ExercisePickerScreen extends StatefulWidget {
  const ExercisePickerScreen({super.key, required this.place});

  final TrainingPlace place;

  @override
  State<ExercisePickerScreen> createState() => _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends State<ExercisePickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final exercises = ExerciseScope.of(context).all
        .where((e) => e.place.matches(widget.place))
        .where((e) => query.isEmpty || e.name.toLowerCase().contains(query))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Add exercise')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) => ExerciseTile(
                exercise: exercises[index],
                trailing: const Icon(Icons.add),
                onTap: () => Navigator.of(context).pop(exercises[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
