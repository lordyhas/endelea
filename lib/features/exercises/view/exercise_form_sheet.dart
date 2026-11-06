import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:material_ui/material_ui.dart';

/// Values entered in [ExerciseFormSheet].
class ExerciseFormResult {
  const ExerciseFormResult({
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.trackingType,
  });

  final String name;
  final MuscleGroup muscleGroup;
  final Equipment equipment;
  final TrackingType trackingType;
}

/// Create or edit a custom exercise.
class ExerciseFormSheet extends StatefulWidget {
  const ExerciseFormSheet({
    this.initialName = '',
    this.initialMuscleGroup = MuscleGroup.chest,
    this.initialEquipment = Equipment.barbell,
    this.initialTrackingType = TrackingType.weightReps,
    this.editing = false,
    super.key,
  });

  final String initialName;
  final MuscleGroup initialMuscleGroup;
  final Equipment initialEquipment;
  final TrackingType initialTrackingType;
  final bool editing;

  static Future<ExerciseFormResult?> show(
    BuildContext context, {
    String initialName = '',
    MuscleGroup? muscleGroup,
    Equipment? equipment,
    TrackingType? trackingType,
    bool editing = false,
  }) {
    return showModalBottomSheet<ExerciseFormResult>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ExerciseFormSheet(
        initialName: initialName,
        initialMuscleGroup: muscleGroup ?? MuscleGroup.chest,
        initialEquipment: equipment ?? Equipment.barbell,
        initialTrackingType: trackingType ?? TrackingType.weightReps,
        editing: editing,
      ),
    );
  }

  @override
  State<ExerciseFormSheet> createState() => _ExerciseFormSheetState();
}

class _ExerciseFormSheetState extends State<ExerciseFormSheet> {
  late final _name = TextEditingController(text: widget.initialName);
  late MuscleGroup _group = widget.initialMuscleGroup;
  late Equipment _equipment = widget.initialEquipment;
  late TrackingType _tracking = widget.initialTrackingType;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = context.l10n.nameRequired);
      return;
    }
    Navigator.of(context).pop(
      ExerciseFormResult(
        name: name,
        muscleGroup: _group,
        equipment: _equipment,
        trackingType: _tracking,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    Widget chips<T>(
      String label,
      List<T> values,
      T selected,
      String Function(T) labelOf,
      ValueChanged<T> onSelected,
    ) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final value in values)
                  ChoiceChip(
                    label: Text(labelOf(value)),
                    selected: value == selected,
                    onSelected: (_) => onSelected(value),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.editing ? l10n.exerciseEdit : l10n.exerciseCreate,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _name,
              autofocus: widget.initialName.isEmpty,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.exerciseNameLabel,
                errorText: _error,
                counterText: '',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            chips(
              l10n.exerciseMuscleGroup,
              MuscleGroup.values,
              _group,
              l10n.muscleGroup,
              (v) => setState(() => _group = v),
            ),
            chips(
              l10n.exerciseEquipment,
              Equipment.values,
              _equipment,
              l10n.equipment,
              (v) => setState(() => _equipment = v),
            ),
            chips(
              l10n.exerciseTracking,
              TrackingType.values,
              _tracking,
              l10n.trackingType,
              (v) => setState(() => _tracking = v),
            ),
            PrimaryActionButton(
              label: widget.editing ? l10n.save : l10n.create,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
