import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/theme/app_typography.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/core/widgets/cards.dart';
import 'package:endelea/core/widgets/charts.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/progress/stats.dart';
import 'package:endelea/features/exercises/bloc/exercise_detail_cubit.dart';
import 'package:endelea/features/exercises/view/exercise_form_sheet.dart';
import 'package:endelea/features/session/view/set_format.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({required this.exerciseId, super.key});

  final String exerciseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExerciseDetailCubit(
        context.read<ExerciseRepository>(),
        context.read<SessionRepository>(),
        exerciseId,
      ),
      child: const ExerciseDetailView(),
    );
  }
}

class ExerciseDetailView extends StatelessWidget {
  const ExerciseDetailView({super.key});

  Future<void> _edit(BuildContext context, Exercise exercise) async {
    final cubit = context.read<ExerciseDetailCubit>();
    final result = await ExerciseFormSheet.show(
      context,
      editing: true,
      initialName: exercise.name,
      muscleGroup: MuscleGroup.fromKey(exercise.muscleGroup),
      equipment: Equipment.fromKey(exercise.equipment),
      trackingType: TrackingType.fromKey(exercise.trackingType),
    );
    if (result == null) return;
    await cubit.update(
      name: result.name,
      muscleGroup: result.muscleGroup,
      equipment: result.equipment,
      trackingType: result.trackingType,
    );
  }

  Future<void> _delete(BuildContext context, Exercise exercise) async {
    final l10n = context.l10n;
    final cubit = context.read<ExerciseDetailCubit>();
    final confirmed = await ConfirmSheet.show(
      context,
      title: l10n.exerciseDelete,
      message: l10n.exerciseDeleteMessage(l10n.exerciseName(exercise)),
      confirmLabel: l10n.delete,
    );
    if (confirmed) await cubit.delete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<ExerciseDetailCubit, ExerciseDetailState>(
      listener: (context, state) {
        if (state is ExerciseDetailNotFound && context.canPop()) {
          context.pop();
        }
      },
      builder: (context, state) {
        final exercise = switch (state) {
          ExerciseDetailLoaded(:final exercise) => exercise,
          _ => null,
        };
        return Scaffold(
          appBar: AppBar(
            title: Text(exercise == null ? '' : l10n.exerciseName(exercise)),
            actions: [
              if (exercise != null && exercise.isCustom) ...[
                IconButton(
                  tooltip: l10n.exerciseEdit,
                  icon: const Icon(PhosphorIconsRegular.pencilSimple),
                  onPressed: () => _edit(context, exercise),
                ),
                IconButton(
                  tooltip: l10n.exerciseDelete,
                  icon: const Icon(PhosphorIconsRegular.trash),
                  onPressed: () => _delete(context, exercise),
                ),
              ],
            ],
          ),
          body: state is! ExerciseDetailLoaded
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  children: [
                    _ExerciseInfo(exercise: state.exercise),
                    const SizedBox(height: AppSpacing.xl),
                    if (state.series.isEmpty)
                      EmptyState(
                        icon: PhosphorIconsDuotone.chartLineUp,
                        title: l10n.exerciseNoHistoryTitle,
                        message: l10n.exerciseNoHistoryMessage,
                      )
                    else
                      ExerciseProgressView(state: state),
                  ],
                ),
        );
      },
    );
  }
}

class _ExerciseInfo extends StatelessWidget {
  const _ExerciseInfo({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final group = MuscleGroup.fromKey(exercise.muscleGroup);
    final equipment = Equipment.fromKey(exercise.equipment);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final label in [
          if (group != null) l10n.muscleGroup(group),
          if (equipment != null) l10n.equipment(equipment),
          l10n.trackingType(TrackingType.fromKey(exercise.trackingType)),
          if (exercise.isCustom) l10n.exerciseCustom,
        ])
          Chip(label: Text(label, style: theme.textTheme.labelLarge)),
      ],
    );
  }
}

enum _Metric { maxWeight, oneRepMax, volume, reps }

/// Records, curve and past sessions of an exercise.
class ExerciseProgressView extends StatefulWidget {
  const ExerciseProgressView({required this.state, super.key});

  final ExerciseDetailLoaded state;

  @override
  State<ExerciseProgressView> createState() => _ExerciseProgressViewState();
}

class _ExerciseProgressViewState extends State<ExerciseProgressView> {
  _Metric? _metric;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final unit = context.select<SettingsCubit, WeightUnit>(
      (c) => c.settings.unit,
    );
    final state = widget.state;
    final type = TrackingType.fromKey(state.exercise.trackingType);
    final records = state.records;
    final metrics = type.usesWeight
        ? const [_Metric.maxWeight, _Metric.oneRepMax, _Metric.volume]
        : const [_Metric.reps];
    final metric = metrics.contains(_metric) ? _metric! : metrics.first;

    String weight(double kg) => l10n.weightWithUnit(kg, unit);
    double? valueOf(ExercisePoint p) => switch (metric) {
      _Metric.maxWeight => p.maxWeightKg,
      _Metric.oneRepMax => p.bestOneRepMaxKg,
      _Metric.volume => p.volumeKg,
      _Metric.reps => p.maxReps?.toDouble(),
    };
    final points = [
      for (final point in state.series)
        if (valueOf(point) case final value?)
          ChartPoint(
            point.date,
            metric == _Metric.reps ? value : kgToUnit(value, unit),
          ),
    ];
    String label(_Metric m) => switch (m) {
      _Metric.maxWeight => l10n.chartMaxWeight,
      _Metric.oneRepMax => l10n.chartOneRepMax,
      _Metric.volume => l10n.chartVolume,
      _Metric.reps => l10n.chartReps,
    };

    final tiles = <(String, String)>[
      if (records.maxWeightKg case final max?)
        (l10n.recordMaxWeight, weight(max)),
      if (records.bestOneRepMaxKg case final best?)
        (l10n.recordOneRepMax, weight(best)),
      if (records.maxReps case final reps?) (l10n.recordMaxReps, '$reps'),
      if (records.bestSessionVolumeKg case final volume?)
        (l10n.recordSessionVolume, weight(volume)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.exerciseRecords.toUpperCase(),
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 2.2,
          children: [
            for (final (title, value) in tiles)
              StatTile(label: title, value: value),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        if (metrics.length > 1)
          SegmentedButton<_Metric>(
            segments: [
              for (final m in metrics)
                ButtonSegment(value: m, label: Text(label(m))),
            ],
            selected: {metric},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                setState(() => _metric = selection.first),
          ),
        const SizedBox(height: AppSpacing.lg),
        ProgressLineChart(
          points: points,
          semanticLabel: label(metric),
          formatValue: (v) => formatDecimal(v, l10n.localeName, maxDecimals: 0),
          formatDate: l10n.shortDate,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.exerciseHistory.toUpperCase(),
          style: theme.textTheme.labelSmall,
        ),
        for (final sets in state.sessions)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.longDate(sets.first.sessionStartedAt)),
            subtitle: Text(
              [
                for (final set in sets)
                  SetColumns(l10n, type, unit).previous(set),
              ].join(' · '),
              style: theme.textTheme.bodyMedium.tabular,
            ),
          ),
      ],
    );
  }
}
