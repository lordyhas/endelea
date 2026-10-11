import 'package:flutter/material.dart';

import '../models/exercise.dart';

class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    super.key,
    required this.exercise,
    this.onTap,
    this.trailing,
  });

  final Exercise exercise;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: Icon(iconForMuscleGroup(exercise.muscleGroup), size: 20),
      ),
      title: Text(exercise.name),
      subtitle: Text(
        '${exercise.muscleGroup.label} · ${exercise.equipment.label}',
      ),
      trailing: trailing,
    );
  }
}

IconData iconForMuscleGroup(MuscleGroup group) => switch (group) {
  .cardio => Icons.directions_run,
  .core => Icons.self_improvement,
  .legs => Icons.directions_walk,
  .fullBody => Icons.accessibility_new,
  _ => Icons.fitness_center,
};
