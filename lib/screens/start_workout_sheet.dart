import 'package:flutter/material.dart';

import '../app/store_scope.dart';
import '../models/exercise.dart';
import 'active_workout_screen.dart';

/// Bottom sheet asking where the user trains before starting a workout.
class StartWorkoutSheet extends StatefulWidget {
  const StartWorkoutSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const StartWorkoutSheet(),
    );
  }

  @override
  State<StartWorkoutSheet> createState() => _StartWorkoutSheetState();
}

class _StartWorkoutSheetState extends State<StartWorkoutSheet> {
  final _name = TextEditingController();
  TrainingPlace _place = TrainingPlace.gym;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _start() {
    final store = StoreScope.of(context);
    final name = _name.text.trim();
    store.start(
      name: name.isEmpty ? '${_place.label} workout' : name,
      place: _place,
    );
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New workout', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Name (optional)',
              hintText: 'Push day, Leg day...',
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<TrainingPlace>(
            segments: const [
              ButtonSegment(
                value: TrainingPlace.gym,
                label: Text('Gym'),
                icon: Icon(Icons.fitness_center),
              ),
              ButtonSegment(
                value: TrainingPlace.home,
                label: Text('Home'),
                icon: Icon(Icons.house_outlined),
              ),
            ],
            selected: {_place},
            onSelectionChanged: (selection) =>
                setState(() => _place = selection.first),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _start,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
