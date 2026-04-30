import 'package:flutter/material.dart';

import '../app/store_scope.dart';
import '../data/rest_timer.dart';
import '../models/exercise.dart';
import '../utils/format.dart';
import '../widgets/elapsed_time.dart';
import '../widgets/rest_timer_bar.dart';
import '../widgets/workout_exercise_card.dart';
import 'exercise_picker_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final _restTimer = RestTimer();

  @override
  void dispose() {
    _restTimer.dispose();
    super.dispose();
  }

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
    _restTimer.stop();
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard workout?'),
        content: const Text('Everything logged in this workout will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _restTimer.stop();
    StoreScope.of(context).discard();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
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
              '${formatWeight(workout.volume)} lifted',
            ),
          ),
        ),
      ),
      body: workout.exercises.isEmpty
          ? const Center(child: Text('Add your first exercise'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final entry in workout.exercises) ...[
                  WorkoutExerciseCard(
                    key: ObjectKey(entry),
                    entry: entry,
                    onChanged: store.touch,
                    onSetDone: _restTimer.start,
                    onRemove: () => store.removeExercise(entry),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 88),
              ],
            ),
      bottomNavigationBar: RestTimerBar(timer: _restTimer),
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
