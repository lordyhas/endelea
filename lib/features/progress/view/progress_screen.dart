import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/core/widgets/cards.dart';
import 'package:endelea/core/widgets/charts.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/data/repositories/body_repository.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/progress/stats.dart';
import 'package:endelea/features/progress/bloc/progress_cubit.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProgressCubit(
        sessions: context.read<SessionRepository>(),
        exercises: context.read<ExerciseRepository>(),
        body: context.read<BodyRepository>(),
        clock: context.read<Clock>(),
      ),
      child: const ProgressView(),
    );
  }
}

class ProgressView extends StatelessWidget {
  const ProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProgress)),
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) => switch (state) {
          ProgressLoading() => const Center(child: CircularProgressIndicator()),
          ProgressLoaded() => _ProgressBody(state: state),
        },
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.state});

  final ProgressLoaded state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final unit = context.select<SettingsCubit, WeightUnit>(
      (c) => c.settings.unit,
    );
    final cubit = context.read<ProgressCubit>();
    final body = state.latestBody;

    String periodLabel(ProgressPeriod period) => switch (period) {
      ProgressPeriod.weeks4 => l10n.periodWeeks4,
      ProgressPeriod.months3 => l10n.periodMonths3,
      ProgressPeriod.year => l10n.periodYear,
      ProgressPeriod.all => l10n.periodAll,
    };

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        SegmentedButton<ProgressPeriod>(
          segments: [
            for (final period in ProgressPeriod.values)
              ButtonSegment(value: period, label: Text(periodLabel(period))),
          ],
          selected: {state.period},
          showSelectedIcon: false,
          onSelectionChanged: (selection) => cubit.setPeriod(selection.first),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: l10n.statSessions,
                value: '${state.sessionCount}',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                label: l10n.statTotalVolume,
                value: l10n.weightWithUnit(state.volumeKg, unit),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                label: l10n.statRecords,
                value: '${state.recordCount}',
              ),
            ),
          ],
        ),
        if (state.isEmpty)
          EmptyState(
            icon: PhosphorIconsDuotone.chartLineUp,
            title: l10n.progressEmptyTitle,
            message: l10n.progressEmptyMessage,
          )
        else ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.weeklyVolumeTitle.toUpperCase(),
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          WeeklyBarChart(
            values: [for (final w in state.weeks) kgToUnit(w.volumeKg, unit)],
            labels: [for (final w in state.weeks) l10n.shortDate(w.weekStart)],
            formatValue: (v) =>
                formatDecimal(v, l10n.localeName, maxDecimals: 0),
            semanticLabel: l10n.weeklyVolumeTitle,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.topExercisesTitle.toUpperCase(),
            style: theme.textTheme.labelSmall,
          ),
          for (final usage in state.topExercises)
            ExerciseTile(
              name: l10n.exerciseName(usage.exercise),
              icon: MuscleGroup.fromKey(usage.exercise.muscleGroup).icon,
              subtitle: l10n.sessionsCount(usage.sessionCount),
              trailing: const Icon(PhosphorIconsRegular.caretRight),
              onTap: () => context.push(AppRoutes.exercise(usage.exercise.id)),
            ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.bodyWeightTitle.toUpperCase(),
          style: theme.textTheme.labelSmall,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(PhosphorIconsRegular.scales),
          title: Text(l10n.bodyWeightTitle),
          subtitle: Text(
            body?.bodyWeightKg == null
                ? l10n.bodyAdd
                : l10n.bodyWeightLatest(
                    l10n.weightWithUnit(body!.bodyWeightKg!, unit),
                  ),
          ),
          trailing: const Icon(PhosphorIconsRegular.caretRight),
          onTap: () => context.push(AppRoutes.body),
        ),
      ],
    );
  }
}
