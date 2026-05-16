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
      title: Row(
        children: [
          Flexible(child: Text(exercise.name)),
          if (exercise.custom) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Custom',
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(color: scheme.onTertiaryContainer),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        '${exercise.muscleGroup.label} · ${exercise.equipment.label}',
      ),
      trailing: trailing,
    );
  }
}

IconData iconForMuscleGroup(MuscleGroup group) {
  switch (group) {
    case MuscleGroup.cardio:
      return Icons.directions_run;
    case MuscleGroup.core:
      return Icons.self_improvement;
    case MuscleGroup.legs:
      return Icons.directions_walk;
    case MuscleGroup.fullBody:
      return Icons.accessibility_new;
    default:
      return Icons.fitness_center;
  }
}
