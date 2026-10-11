import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../utils/format.dart';

/// Card listing the sets of one exercise in the active workout.
class WorkoutExerciseCard extends StatelessWidget {
  const WorkoutExerciseCard({
    super.key,
    required this.entry,
    required this.onChanged,
    required this.onRemove,
  });

  final WorkoutExercise entry;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  void _addSet() {
    final previous = entry.sets.isEmpty ? null : entry.sets.last;
    entry.sets.add(
      previous == null ? WorkoutSet() : (previous.copy()..done = false),
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tracking = entry.exercise.tracking;
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.exercise.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${entry.completedSets.length}/${entry.sets.length}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color:
                        entry.sets.isNotEmpty &&
                            entry.completedSets.length == entry.sets.length
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove exercise',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            for (var i = 0; i < entry.sets.length; i++)
              Dismissible(
                key: ObjectKey(entry.sets[i]),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  color: theme.colorScheme.errorContainer,
                  child: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                onDismissed: (_) {
                  entry.sets.removeAt(i);
                  onChanged();
                },
                child: _SetRow(
                  index: i,
                  set: entry.sets[i],
                  tracking: tracking,
                  onChanged: onChanged,
                ),
              ),
            TextButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add),
              label: const Text('Add set'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.index,
    required this.set,
    required this.tracking,
    required this.onChanged,
  });

  final int index;
  final WorkoutSet set;
  final TrackingType tracking;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: set.done ? scheme.primaryContainer.withValues(alpha: 0.5) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),

          if (tracking == TrackingType.weightReps) ...[
            Expanded(
              child: _NumberField(
                label: 'kg',
                initial: set.weight == 0 ? '' : formatNumber(set.weight),
                decimal: true,
                onChanged: (value) {
                  set.weight = double.tryParse(value) ?? 0;
                  onChanged();
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (tracking != TrackingType.duration)
            Expanded(
              child: _NumberField(
                label: 'reps',
                initial: set.reps == 0 ? '' : '${set.reps}',
                onChanged: (value) {
                  set.reps = int.tryParse(value) ?? 0;
                  onChanged();
                },
              ),
            )
          else
            Expanded(
              child: _NumberField(
                label: 'sec',
                initial: set.seconds == 0 ? '' : '${set.seconds}',
                onChanged: (value) {
                  set.seconds = int.tryParse(value) ?? 0;
                  onChanged();
                },
              ),
            ),
          IconButton(
            tooltip: set.done ? 'Undo' : 'Done',
            onPressed: () {
              set.done = !set.done;
              if (set.done) HapticFeedback.lightImpact();
              onChanged();
            },
            icon: Icon(
              set.done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: set.done ? scheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.initial,
    required this.onChanged,
    this.decimal = false,
  });

  final String label;
  final String initial;
  final bool decimal;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimal ? RegExp(r'^\d*[.,]?\d*') : RegExp(r'\d*'),
        ),
      ],
      textAlign: TextAlign.center,
      decoration: InputDecoration(suffixText: label, isDense: true),
      onChanged: (value) => onChanged(value.replaceAll(',', '.')),
    );
  }
}
