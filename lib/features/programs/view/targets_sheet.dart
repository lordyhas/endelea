import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/value_stepper.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:endelea/features/settings/data/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Bottom sheet editing the targets of a planned exercise.
class TargetsSheet extends StatefulWidget {
  const TargetsSheet({required this.planned, super.key});

  final PlannedExercise planned;

  static Future<ExerciseTargets?> show(
    BuildContext context, {
    required PlannedExercise planned,
  }) {
    return showModalBottomSheet<ExerciseTargets>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: TargetsSheet(planned: planned),
      ),
    );
  }

  @override
  State<TargetsSheet> createState() => _TargetsSheetState();
}

class _TargetsSheetState extends State<TargetsSheet> {
  late final ProgramExercise _plan = widget.planned.plan;
  late int _sets = _plan.targetSets;
  late int _repsMin = _plan.targetRepsMin ?? 8;
  late int _repsMax = _plan.targetRepsMax ?? _repsMin;
  late double _weightKg = _plan.targetWeightKg ?? 0;
  late int _duration = _plan.targetDurationSeconds ?? 60;
  late int _rest = _plan.restSeconds;
  late final _notes = TextEditingController(text: _plan.notes);

  TrackingType get _type =>
      TrackingType.fromKey(widget.planned.exercise.trackingType);

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    final type = _type;
    Navigator.of(context).pop(
      ExerciseTargets(
        sets: _sets,
        repsMin: type.usesReps ? _repsMin : null,
        repsMax: type.usesReps ? _repsMax : null,
        weightKg: type.usesWeight && _weightKg > 0 ? _weightKg : null,
        durationSeconds: type == TrackingType.duration ? _duration : null,
        restSeconds: _rest,
        notes: _notes.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = context.select<SettingsCubit, AppSettings>(
      (c) => c.settings,
    );
    final type = _type;

    Widget field(String label, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );

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
              l10n.exerciseName(widget.planned.exercise),
              style: theme.textTheme.titleLarge,
            ),
            Text(l10n.targetsTitle, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpacing.lg),
            field(
              l10n.targetSets,
              ValueStepper(
                value: _sets.toDouble(),
                step: 1,
                min: 1,
                max: 20,
                label: l10n.targetSets,
                unitLabel: l10n.targetSets.toLowerCase(),
                semanticUnit: l10n.targetSets.toLowerCase(),
                onChanged: (v) => setState(() => _sets = v.round()),
              ),
            ),
            if (type.usesReps)
              Row(
                children: [
                  Expanded(
                    child: field(
                      l10n.targetRepsMin,
                      RepsStepper(
                        reps: _repsMin,
                        onChanged: (v) => setState(() {
                          _repsMin = v;
                          if (_repsMax < v) _repsMax = v;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: field(
                      l10n.targetRepsMax,
                      RepsStepper(
                        reps: _repsMax,
                        onChanged: (v) => setState(() {
                          _repsMax = v;
                          if (_repsMin > v) _repsMin = v;
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            if (type.usesWeight)
              field(
                _weightKg > 0
                    ? l10n.weightLabel
                    : '${l10n.weightLabel} · ${l10n.targetNoWeight}',
                WeightStepper(
                  weightKg: _weightKg,
                  unit: settings.unit,
                  step: settings.effectiveWeightStep,
                  onChanged: (v) => setState(() => _weightKg = v),
                ),
              ),
            if (type == TrackingType.duration)
              field(
                l10n.durationLabel,
                DurationStepper(
                  seconds: _duration,
                  onChanged: (v) => setState(() => _duration = v),
                ),
              ),
            field(
              l10n.restTitle,
              DurationStepper(
                seconds: _rest,
                step: 15,
                label: l10n.restTitle,
                onChanged: (v) => setState(() => _rest = v),
              ),
            ),
            field(
              l10n.notes,
              TextField(
                controller: _notes,
                maxLines: 3,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            PrimaryActionButton(label: l10n.save, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
