import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/settings_scope.dart';
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
    this.onSetDone,
    this.onMoveUp,
    this.onMoveDown,
    this.lastPerformance,
  });

  final WorkoutExercise entry;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  /// Called when a set gets checked, used to start the rest timer.
  final VoidCallback? onSetDone;

  /// Move the exercise in the workout; null when it cannot move that way.
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  /// Short summary of the previous time this exercise was done.
  final String? lastPerformance;

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
                PopupMenuButton<VoidCallback>(
                  tooltip: 'Exercise options',
                  onSelected: (action) => action(),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: onMoveUp,
                      enabled: onMoveUp != null,
                      child: const Text('Move up'),
                    ),
                    PopupMenuItem(
                      value: onMoveDown,
                      enabled: onMoveDown != null,
                      child: const Text('Move down'),
                    ),
                    PopupMenuItem(
                      value: onRemove,
                      child: const Text('Remove exercise'),
                    ),
                  ],
                ),
              ],
            ),
            if (lastPerformance != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Last time: $lastPerformance',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
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
                  onDone: onSetDone,
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
    this.onDone,
  });

  final int index;
  final WorkoutSet set;
  final TrackingType tracking;
  final VoidCallback onChanged;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unit = SettingsScope.of(context).settings.weightUnit;
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
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                set.warmUp = !set.warmUp;
                onChanged();
              },
              child: Tooltip(
                message: set.warmUp ? 'Warm-up set' : 'Tap for a warm-up set',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    set.warmUp ? 'W' : '${index + 1}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: set.warmUp ? scheme.tertiary : null),
                  ),
                ),
              ),
            ),
          ),
          if (tracking == TrackingType.weightReps) ...[
            Expanded(
              child: _NumberField(
                key: ValueKey(unit),
                label: unit.label,
                initial: set.weight == 0
                    ? ''
                    : formatNumber(unit.fromKg(set.weight)),
                decimal: true,
                onChanged: (value) {
                  set.weight = unit.toKg(double.tryParse(value) ?? 0);
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
              if (set.done) onDone?.call();
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
    super.key,
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
