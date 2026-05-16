import 'package:flutter/material.dart';

import '../app/exercise_scope.dart';
import '../models/exercise.dart';
import '../widgets/exercise_tile.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});

  final Exercise exercise;

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${exercise.name}?'),
        content: const Text(
          'It will no longer be offered when adding exercises. '
          'Past workouts are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    ExerciseScope.of(context).remove(exercise);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name),
        actions: [
          if (exercise.custom)
            IconButton(
              tooltip: 'Delete',
              onPressed: () => _delete(context),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
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
