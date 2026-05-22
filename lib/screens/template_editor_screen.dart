import 'package:flutter/material.dart';

import '../app/template_scope.dart';
import '../models/exercise.dart';
import '../models/workout_template.dart';
import 'exercise_picker_screen.dart';

/// Creates a workout template.
class TemplateEditorScreen extends StatefulWidget {
  const TemplateEditorScreen({super.key});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final _name = TextEditingController();
  TrainingPlace _place = TrainingPlace.gym;
  final List<TemplateExercise> _exercises = [];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    final exercise = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(builder: (_) => ExercisePickerScreen(place: _place)),
    );
    if (exercise == null) return;
    setState(() => _exercises.add(TemplateExercise(exercise: exercise)));
  }

  void _save() {
    final name = _name.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (name.isEmpty || _exercises.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Add a name and at least one exercise')),
      );
      return;
    }
    TemplateScope.of(context)
        .create(name: name, place: _place, exercises: _exercises);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New routine'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Name'),
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
          const SizedBox(height: 16),
          for (final entry in _exercises)
            ListTile(
              key: ObjectKey(entry),
              contentPadding: EdgeInsets.zero,
              title: Text(entry.exercise.name),
              subtitle: Text('${entry.sets} sets'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Fewer sets',
                    onPressed: entry.sets > 1
                        ? () => setState(() => entry.sets--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  IconButton(
                    tooltip: 'More sets',
                    onPressed: () => setState(() => entry.sets++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    onPressed: () => setState(() => _exercises.remove(entry)),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addExercise,
            icon: const Icon(Icons.add),
            label: const Text('Add exercise'),
          ),
        ],
      ),
    );
  }
}
