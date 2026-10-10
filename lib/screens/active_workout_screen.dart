import 'package:flutter/material.dart';

import '../app/settings_scope.dart';
import '../app/store_scope.dart';
import '../models/exercise.dart';
import '../models/workout.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/elapsed_time.dart';
import '../widgets/workout_exercise_card.dart';
import 'exercise_picker_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  Future<void> _finish() async {
    final store = StoreScope.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (store.active!.completedSetCount == 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Complete at least one set first')),
      );
      return;
    }
    final workout = store.finish()!;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${workout.name} saved · ${formatDuration(workout.duration)}',
        ),
      ),
    );
  }

  Future<void> _discard() async {
    final confirmed = await confirm(
      context,
      title: 'Discard workout?',
      message: 'Everything logged in this workout will be lost.',
      action: 'Discard',
    );
    if (!confirmed || !mounted) return;
    StoreScope.of(context).discard();
    Navigator.of(context).pop();
  }

  Future<void> _remove(WorkoutExercise entry) async {
    if (entry.completedSets.isNotEmpty) {
      final confirmed = await confirm(
        context,
        title: 'Remove ${entry.exercise.name}?',
        message: 'Its completed sets will be lost.',
        action: 'Remove',
      );
      if (!confirmed || !mounted) return;
    }
    StoreScope.of(context).removeExercise(entry);
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final settings = SettingsScope.of(context).settings;
    final workout = store.active;
    if (workout == null) {
      return const Scaffold(body: Center(child: Text('No active workout')));
    }
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(workout.name),
            ElapsedTime(
              since: workout.startedAt,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: _finish, child: const Text('Finish')),
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              PopupMenuItem(onTap: _discard, child: const Text('Discard')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${workout.completedSetCount} sets · '
              '${formatWeight(workout.volume, settings.weightUnit)} lifted',
            ),
          ),
        ),
      ),
      body: workout.exercises.isEmpty
          ? const Center(child: Text('Add your first exercise'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final (index, entry) in workout.exercises.indexed) ...[
                  WorkoutExerciseCard(
                    key: ObjectKey(entry),
                    entry: entry,
                    onMoveUp: index == 0
                        ? null
                        : () => store.moveExercise(index, index - 1),
                    onMoveDown: index == workout.exercises.length - 1
                        ? null
                        : () => store.moveExercise(index, index + 1),
                    onChanged: store.touch,
                    onRemove: () => _remove(entry),
                  ),

                  const SizedBox(height: 12),
                ],
                TextFormField(
                  initialValue: workout.notes,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'How did it feel?',
                  ),
                  onChanged: (value) => workout.notes = value,
                ),
                const SizedBox(height: 88),
              ],
            ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final exercise = await Navigator.of(context).push<Exercise>(
            MaterialPageRoute(
              builder: (_) => ExercisePickerScreen(place: workout.place),
            ),
          );
          if (exercise != null) store.addExercise(exercise);
        },
        icon: const Icon(Icons.add),
        label: const Text('Exercise'),
      ),
    );
  }
}
