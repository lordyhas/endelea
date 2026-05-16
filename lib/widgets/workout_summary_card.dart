import 'package:flutter/material.dart';

import '../app/settings_scope.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../utils/format.dart';

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({super.key, required this.workout, this.onTap});

  final Workout workout;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = SettingsScope.of(context).settings.weightUnit;
    return Card.filled(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    workout.place == TrainingPlace.home
                        ? Icons.house_outlined
                        : Icons.fitness_center,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      workout.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    formatDay(workout.startedAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                workout.exercises.map((e) => e.exercise.name).join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                children: [
                  _Stat(Icons.schedule, formatDuration(workout.duration)),
                  _Stat(Icons.repeat, '${workout.completedSetCount} sets'),
                  if (workout.volume > 0)
                    _Stat(
                      Icons.scale_outlined,
                      formatWeight(workout.volume, unit),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
