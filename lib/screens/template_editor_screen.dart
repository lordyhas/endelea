import 'package:flutter/material.dart';

import '../app/template_scope.dart';
import '../models/exercise.dart';
import '../models/workout_template.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/show_message.dart';
import 'exercise_picker_screen.dart';

/// Creates a workout template, or edits [template] when given.
class TemplateEditorScreen extends StatefulWidget {
  const TemplateEditorScreen({super.key, this.template});

  final WorkoutTemplate? template;

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  late final _name = TextEditingController(text: widget.template?.name);
  late TrainingPlace _place = widget.template?.place ?? TrainingPlace.gym;

  /// Copies, so that cancelling leaves the template untouched.
  late final List<TemplateExercise> _exercises = [
    for (final entry in widget.template?.exercises ?? <TemplateExercise>[])
      TemplateExercise(exercise: entry.exercise, sets: entry.sets),
  ];

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
    if (name.isEmpty || _exercises.isEmpty) {
      showMessage(context, 'Add a name and at least one exercise');
      return;
    }
    final store = TemplateScope.of(context);
    final template = widget.template;
    if (template == null) {
      store.create(name: name, place: _place, exercises: _exercises);
    } else {
      template
        ..name = name
        ..place = _place
        ..exercises.clear()
        ..exercises.addAll(_exercises);
      store.touch();
    }
    Navigator.of(context).pop();
  }

  /// Copies the saved routine and opens the copy instead.
  void _duplicate() {
    final copy = TemplateScope.of(context).duplicate(widget.template!);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TemplateEditorScreen(template: copy),
      ),
    );
  }

  Future<void> _delete() async {
    final template = widget.template!;
    final confirmed = await confirm(
      context,
      title: 'Delete ${template.name}?',
      message: 'Workouts done with this routine are kept.',
      action: 'Delete',
    );
    if (!confirmed || !mounted) return;
    TemplateScope.of(context).remove(template);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template == null ? 'New routine' : 'Edit routine'),
        actions: [
          if (widget.template != null) ...[
            IconButton(
              tooltip: 'Duplicate',
              onPressed: _duplicate,
              icon: const Icon(Icons.copy_outlined),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
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
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: (from, to) => setState(
              () => _exercises.insert(to, _exercises.removeAt(from)),
            ),
            children: [
              for (final (index, entry) in _exercises.indexed)
                ListTile(
                  key: ObjectKey(entry),
                  contentPadding: EdgeInsets.zero,
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
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
                        onPressed: () =>
                            setState(() => _exercises.remove(entry)),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
            ],
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
