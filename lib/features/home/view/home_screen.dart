import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/cards.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/features/home/bloc/home_cubit.dart';
import 'package:endelea/features/home/view/resume_session_card.dart';
import 'package:endelea/features/session/bloc/session_bloc.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        programs: context.read<ProgramRepository>(),
        sessions: context.read<SessionRepository>(),
        exercises: context.read<ExerciseRepository>(),
        clock: context.read<Clock>(),
      ),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static String _greeting(AppLocalizations l10n, DateTime now) {
    final hour = now.hour;
    if (hour >= 18 || hour < 5) return l10n.greetingEvening;
    if (hour >= 12) return l10n.greetingAfternoon;
    return l10n.greetingMorning;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = context.read<Clock>().now();
    return Scaffold(
      appBar: AppBar(
        title: Text(_greeting(l10n, now)),
        actions: [
          const HomeSyncChip(),
          if (kDebugMode)
            IconButton(
              tooltip: l10n.galleryTitle,
              icon: const Icon(PhosphorIconsRegular.squaresFour),
              onPressed: () => context.push(AppRoutes.gallery),
            ),
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(PhosphorIconsRegular.gearSix),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeLoading() => const Center(child: CircularProgressIndicator()),
          HomeLoaded(hasPrograms: false) => const _HomeEmpty(),
          HomeLoaded() => _HomeBody(state: state),
        },
      ),
    );
  }
}

/// Sync state in the header; replaced by the real chip with the sync
/// (phase 7).
class HomeSyncChip extends StatelessWidget {
  const HomeSyncChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: SyncStatusChip(
        status: SyncStatus.disabled,
        onTap: () => context.push(AppRoutes.settings),
      ),
    );
  }
}

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        const ResumeSessionCard(),
        EmptyState(
          icon: PhosphorIconsDuotone.listChecks,
          title: l10n.programsEmptyTitle,
          message: l10n.homeEmptyMessage,
          action: Column(
            children: [
              PrimaryActionButton(
                label: l10n.homeCreateProgram,
                icon: PhosphorIconsRegular.plus,
                onPressed: () =>
                    StatefulNavigationShell.of(context).goBranch(1),
              ),
              const SizedBox(height: AppSpacing.sm),
              SecondaryButton(
                label: l10n.sessionFree,
                expand: true,
                onPressed: () =>
                    context.read<SessionBloc>().add(const SessionStarted()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.state});

  final HomeLoaded state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final unit = context.select<SettingsCubit, WeightUnit>(
      (c) => c.settings.unit,
    );
    final running = context.select<SessionBloc, bool>(
      (bloc) => bloc.state is SessionRunning,
    );
    final next = state.next;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        if (running) ...[
          const ResumeSessionCard(),
          const SizedBox(height: AppSpacing.lg),
        ] else if (next != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.sessionNextTitle.toUpperCase(),
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(next.day.day.name, style: theme.textTheme.headlineSmall),
                  Text(
                    '${next.program.name} · '
                    '${l10n.dayExercises(next.day.exerciseCount)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryActionButton(
                    label: l10n.start,
                    icon: PhosphorIconsRegular.play,
                    onPressed: () => context.read<SessionBloc>().add(
                      SessionStarted(programDayId: next.day.day.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StatTile(
                label: l10n.statSessionsWeek,
                value: '${state.sessionsThisWeek}',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                label: l10n.statVolumeWeek,
                value: l10n.weightWithUnit(state.volumeThisWeekKg, unit),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                label: l10n.statStreak,
                value: '${state.weekStreak}',
              ),
            ),
          ],
        ),
        if (state.lastRecords.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.homeLastRecords.toUpperCase(),
            style: theme.textTheme.labelSmall,
          ),
          for (final record in state.lastRecords)
            ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () => context.push(AppRoutes.exercise(record.exercise.id)),
              title: Text(l10n.exerciseName(record.exercise)),
              subtitle: Text(
                [
                  l10n.recordLabel(record.event.type),
                  if (record.event.set.weightKg case final kg?)
                    '${l10n.weightWithUnit(kg, unit)} × ${record.event.set.reps ?? '–'}',
                  l10n.shortDate(record.event.date),
                ].join(' · '),
              ),
              trailing: const PrBadge(),
            ),
        ],
      ],
    );
  }
}
