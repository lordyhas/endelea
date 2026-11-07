import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/cards.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/core/widgets/set_row.dart';
import 'package:endelea/core/widgets/value_stepper.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/progress/stats.dart';
import 'package:endelea/features/history/bloc/session_detail_cubit.dart';
import 'package:endelea/features/session/view/set_format.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:endelea/features/settings/data/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// A past session: exercises and sets, edited after the fact.
class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SessionDetailCubit(context.read<SessionRepository>(), sessionId),
      child: const SessionDetailView(),
    );
  }
}

class SessionDetailView extends StatelessWidget {
  const SessionDetailView({super.key});

  Future<void> _delete(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<SessionDetailCubit>();
    final confirmed = await ConfirmSheet.show(
      context,
      title: l10n.sessionDelete,
      message: l10n.sessionDeleteMessage,
      confirmLabel: l10n.delete,
    );
    if (confirmed) await cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = context.select<SettingsCubit, AppSettings>(
      (c) => c.settings,
    );
    return BlocConsumer<SessionDetailCubit, SessionDetailState>(
      listener: (context, state) {
        if (state is SessionDetailNotFound && context.canPop()) context.pop();
      },
      builder: (context, state) {
        final details = state is SessionDetailLoaded ? state.details : null;
        return Scaffold(
          appBar: AppBar(
            title: Text(details?.session.name ?? l10n.sessionFree),
            actions: [
              if (details != null)
                IconButton(
                  tooltip: l10n.sessionDelete,
                  icon: const Icon(PhosphorIconsRegular.trash),
                  onPressed: () => _delete(context),
                ),
            ],
          ),
          body: details == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  children: [
                    Text(
                      '${l10n.longDate(details.session.startedAt)} · '
                      '${l10n.time(details.session.startedAt)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _Stats(details: details, settings: settings),
                    if (details.session.notes case final notes?) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(notes, style: theme.textTheme.bodyMedium),
                    ],
                    for (final exercise in details.exercises)
                      _ExerciseSets(exercise: exercise, settings: settings),
                  ],
                ),
        );
      },
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.details, required this.settings});

  final SessionDetails details;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = sessionStats(details, recordCount: 0);
    return Row(
      children: [
        Expanded(
          child: StatTile(
            label: l10n.summaryDuration,
            value: l10n.durationText(stats.duration),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatTile(
            label: l10n.summaryVolume,
            value: l10n.weightWithUnit(stats.volumeKg, settings.unit),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatTile(label: l10n.summarySets, value: '${stats.setCount}'),
        ),
      ],
    );
  }
}

class _ExerciseSets extends StatelessWidget {
  const _ExerciseSets({required this.exercise, required this.settings});

  final SessionExerciseDetails exercise;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final columns = SetColumns(l10n, exercise.trackingType, settings.unit);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.exerciseName(exercise.exercise),
            style: theme.textTheme.titleMedium,
          ),
          if (exercise.entry.notes case final notes?)
            Text(notes, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          for (final (i, set) in exercise.sets.indexed) ...[
            SetRow(
              index: i + 1,
              state: SetRowState.done,
              isWarmup: set.isWarmup,
              value: columns.value(
                weightKg: set.weightKg,
                reps: set.reps,
                durationSeconds: set.durationSeconds,
                distanceMeters: set.distanceMeters,
              ),
              secondary: columns.secondary(
                reps: set.reps,
                durationSeconds: set.durationSeconds,
              ),
              onTap: () => _edit(context, set),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, SetEntry set) async {
    final cubit = context.read<SessionDetailCubit>();
    final values = await showModalBottomSheet<SetValues>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _SetEditSheet(
        set: set,
        type: exercise.trackingType,
        settings: settings,
      ),
    );
    if (values != null) await cubit.updateSet(set.id, values);
  }
}

/// Corrects the values of a past set.
class _SetEditSheet extends StatefulWidget {
  const _SetEditSheet({
    required this.set,
    required this.type,
    required this.settings,
  });

  final SetEntry set;
  final TrackingType type;
  final AppSettings settings;

  @override
  State<_SetEditSheet> createState() => _SetEditSheetState();
}

class _SetEditSheetState extends State<_SetEditSheet> {
  late SetValues _values = valuesOf(widget.set);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = widget.type;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.editSet, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            if (type.usesWeight) ...[
              WeightStepper(
                weightKg: _values.weightKg ?? 0,
                unit: widget.settings.unit,
                step: widget.settings.effectiveWeightStep,
                onChanged: (kg) => setState(
                  () => _values = SetValues(
                    weightKg: kg,
                    reps: _values.reps,
                    isWarmup: _values.isWarmup,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (type.usesReps) ...[
              RepsStepper(
                reps: _values.reps ?? 0,
                onChanged: (reps) =>
                    setState(() => _values = _values.copyWith(reps: reps)),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (type.usesDistance) ...[
              ValueStepper(
                value: (_values.distanceMeters ?? 0) / 1000,
                step: 0.1,
                decimals: 2,
                label: l10n.distanceLabel,
                unitLabel: l10n.setColumnDistance,
                semanticUnit: l10n.setColumnDistance,
                onChanged: (km) => setState(
                  () => _values = _values.copyWith(
                    distanceMeters: (km * 1000).roundToDouble(),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (type.usesDuration) ...[
              DurationStepper(
                seconds: _values.durationSeconds ?? 0,
                onChanged: (seconds) => setState(
                  () => _values = _values.copyWith(durationSeconds: seconds),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.md),
            PrimaryActionButton(
              label: l10n.save,
              onPressed: () => Navigator.of(context).pop(_values),
            ),
          ],
        ),
      ),
    );
  }
}
