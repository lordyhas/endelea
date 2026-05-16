import 'package:flutter/material.dart';

import '../app/exercise_scope.dart';
import '../models/exercise.dart';

/// Form to create a custom exercise. Pops with the created [Exercise].
class CreateExerciseScreen extends StatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  State<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  MuscleGroup _muscleGroup = MuscleGroup.chest;
  Equipment _equipment = Equipment.none;
  TrainingPlace _place = TrainingPlace.both;
  TrackingType _tracking = TrackingType.weightReps;

  static const _trackingLabels = {
    TrackingType.weightReps: 'Weight & reps',
    TrackingType.reps: 'Reps only',
    TrackingType.duration: 'Duration',
  };

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final exercise = ExerciseScope.of(context).add(
      name: _name.text.trim(),
      muscleGroup: _muscleGroup,
      equipment: _equipment,
      place: _place,
      tracking: _tracking,
      description: _description.text.trim(),
    );
    Navigator.of(context).pop(exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New exercise'),
        actions: [TextButton(onPressed: _save, child: const Text('Save'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Give the exercise a name'
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MuscleGroup>(
              initialValue: _muscleGroup,
              decoration: const InputDecoration(labelText: 'Muscle group'),
              items: [
                for (final group in MuscleGroup.values)
                  DropdownMenuItem(value: group, child: Text(group.label)),
              ],
              onChanged: (value) => setState(() => _muscleGroup = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Equipment>(
              initialValue: _equipment,
              decoration: const InputDecoration(labelText: 'Equipment'),
              items: [
                for (final equipment in Equipment.values)
                  DropdownMenuItem(
                    value: equipment,
                    child: Text(equipment.label),
                  ),
              ],
              onChanged: (value) => setState(() => _equipment = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TrackingType>(
              initialValue: _tracking,
              decoration: const InputDecoration(labelText: 'Tracked as'),
              items: [
                for (final entry in _trackingLabels.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (value) => setState(() => _tracking = value!),
            ),
            const SizedBox(height: 16),
            SegmentedButton<TrainingPlace>(
              segments: [
                for (final place in TrainingPlace.values)
                  ButtonSegment(value: place, label: Text(place.label)),
              ],
              selected: {_place},
              onSelectionChanged: (selection) =>
                  setState(() => _place = selection.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'How to (optional)',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
