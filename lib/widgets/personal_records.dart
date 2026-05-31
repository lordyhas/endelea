import 'package:flutter/material.dart';

import '../data/exercise_progress.dart';
import '../models/exercise.dart';
import '../models/settings.dart';
import '../utils/format.dart';

/// Best results of an exercise, adapted to how it is tracked.
class PersonalRecords extends StatelessWidget {
  const PersonalRecords({
    super.key,
    required this.progress,
    required this.unit,
  });

  final ExerciseProgress progress;
  final WeightUnit unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (progress.isEmpty) {
      return Text(
        'No record yet. Log this exercise in a workout to track it.',
        style: theme.textTheme.bodyMedium,
      );
    }
    final records = switch (progress.exercise.tracking) {
      TrackingType.weightReps => [
        ('Heaviest', formatWeight(progress.heaviestWeight, unit)),
        ('Best 1RM', formatWeight(progress.bestOneRepMax, unit)),
        ('Most reps', '${progress.mostReps}'),
      ],
      TrackingType.reps => [('Most reps', '${progress.mostReps}')],
      TrackingType.duration => [
        ('Longest', formatDuration(Duration(seconds: progress.longestSeconds))),
      ],
    };
    final count = progress.points.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final (label, value) in records)
              Expanded(
                child: Card.filled(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(value, style: theme.textTheme.titleLarge),
                        Text(label, style: theme.textTheme.labelMedium),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Done in $count workout${count == 1 ? '' : 's'}, '
          'last on ${formatDay(progress.last!.date)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
