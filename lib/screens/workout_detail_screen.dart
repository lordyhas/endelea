import 'package:flutter/material.dart';

import '../app/settings_scope.dart';
import '../app/store_scope.dart';
import '../app/template_scope.dart';
import '../models/exercise.dart';
import '../models/settings.dart';
import '../models/workout.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/show_message.dart';
import 'active_workout_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.workout});

  final Workout workout;

  void _saveAsRoutine(BuildContext context) {
    final template = TemplateScope.of(context).saveWorkout(workout);
    showMessage(context, 'Routine "${template.name}" created');
  }

  void _repeat(BuildContext context) {
    final store = StoreScope.of(context);
    if (store.active != null) {
      showMessage(context, 'Finish your current workout first');
      return;
    }
    store.repeat(workout);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await confirm(
      context,
      title: 'Delete workout?',
      message: 'It will be removed from your history and stats.',
      action: 'Delete',
    );
    if (!confirmed || !context.mounted) return;
    StoreScope.of(context).delete(workout);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unit = SettingsScope.of(context).settings.weightUnit;
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
        actions: [
          PopupMenuButton<void>(
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: () => _repeat(context),
                child: const Text('Repeat workout'),
              ),
              PopupMenuItem(
                onTap: () => _saveAsRoutine(context),
                child: const Text('Save as routine'),
              ),
              PopupMenuItem(
                onTap: () => _delete(context),
                child: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
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
          if (workout.notes.trim().isNotEmpty) ...[
            Card.filled(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notes, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(workout.notes.trim())),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          for (final entry in workout.exercises) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.exercise.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (entry.volume > 0)
                  Text(
                    formatWeight(entry.volume, unit),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
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
  ) => switch (tracking) {
    .weightReps => '${formatWeight(set.weight, unit)} × ${set.reps}',
    .reps => '${set.reps} reps',
    .duration => formatDuration(Duration(seconds: set.seconds)),
  };
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
