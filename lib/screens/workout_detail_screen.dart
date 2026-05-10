import 'package:flutter/material.dart';

import '../app/settings_scope.dart';
import '../models/exercise.dart';
import '../models/settings.dart';
import '../models/workout.dart';
import '../utils/format.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = SettingsScope.of(context).settings.weightUnit;
    return Scaffold(
      appBar: AppBar(title: Text(workout.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${formatDay(workout.startedAt)} · ${formatTime(workout.startedAt)}'
            ' · ${workout.place.label}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metric('Duration', formatDuration(workout.duration)),
              _Metric('Sets', '${workout.completedSetCount}'),
              _Metric('Volume', formatWeight(workout.volume, unit)),
            ],
          ),
          const SizedBox(height: 24),
          for (final entry in workout.exercises) ...[
            Text(entry.exercise.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            for (var i = 0; i < entry.sets.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  'Set ${i + 1}   '
                  '${_describe(entry.exercise.tracking, entry.sets[i], unit)}',
                ),
              ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  static String _describe(
    TrackingType tracking,
    WorkoutSet set,
    WeightUnit unit,
  ) {
    switch (tracking) {
      case TrackingType.weightReps:
        return '${formatWeight(set.weight, unit)} × ${set.reps}';
      case TrackingType.reps:
        return '${set.reps} reps';
      case TrackingType.duration:
        return formatDuration(Duration(seconds: set.seconds));
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.titleLarge),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}
