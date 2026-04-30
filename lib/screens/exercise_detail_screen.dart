import 'package:flutter/material.dart';

import '../models/exercise.dart';
import '../widgets/exercise_tile.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              iconForMuscleGroup(exercise.muscleGroup),
              size: 40,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              Chip(label: Text(exercise.muscleGroup.label)),
              Chip(label: Text(exercise.equipment.label)),
              Chip(label: Text(exercise.place.label)),
            ],
          ),
          const SizedBox(height: 24),
          Text('How to', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(exercise.description, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
