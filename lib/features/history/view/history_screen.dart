import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/utils/date_utils.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/features/history/bloc/history_cubit.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HistoryCubit(
        context.read<SessionRepository>(),
        context.read<ExerciseRepository>(),
      ),
      child: const HistoryView(),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navHistory)),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) => switch (state) {
          HistoryLoading() => const Center(child: CircularProgressIndicator()),
          HistoryLoaded(items: []) => EmptyState(
            icon: PhosphorIconsDuotone.clockCounterClockwise,
            title: l10n.historyEmptyTitle,
            message: l10n.historyEmptyMessage,
          ),
          HistoryLoaded(:final items) => _HistoryList(items: items),
        },
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.items});

  final List<HistoryItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final unit = context.select<SettingsCubit, WeightUnit>(
      (c) => c.settings.unit,
    );
    final thisWeek = startOfWeek(DateTime.now());

    // Group by week, keeping the most recent first.
    final groups = <DateTime, List<HistoryItem>>{};
    for (final item in items) {
      (groups[startOfWeek(item.details.session.startedAt)] ??= []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        for (final MapEntry(key: week, value: sessions) in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.lg,
              AppSpacing.screen,
              AppSpacing.xs,
            ),
            child: Text(
              (week == thisWeek
                      ? l10n.historyThisWeek
                      : l10n.historyWeekOf(l10n.shortDate(week)))
                  .toUpperCase(),
              style: theme.textTheme.labelSmall,
            ),
          ),
          for (final item in sessions)
            ListTile(
              onTap: () => context.push(
                AppRoutes.historySession(item.details.session.id),
              ),
              title: Text(item.details.session.name ?? l10n.sessionFree),
              subtitle: Text(
                [
                  l10n.longDate(item.details.session.startedAt),
                  l10n.durationText(item.stats.duration),
                  l10n.weightWithUnit(item.stats.volumeKg, unit),
                ].join(' · '),
              ),
              trailing: item.stats.recordCount == 0
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIconsFill.trophy,
                          size: AppSizes.iconDense,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${item.stats.recordCount}',
                          semanticsLabel: l10n.recordsCount(
                            item.stats.recordCount,
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ],
    );
  }
}
