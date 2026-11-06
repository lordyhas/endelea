import 'dart:async';

import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/cards.dart';
import 'package:endelea/data/repositories/session_repository.dart';
import 'package:endelea/domain/progress/personal_records.dart';
import 'package:endelea/domain/progress/session_summary.dart';
import 'package:endelea/features/session/bloc/session_bloc.dart';
import 'package:endelea/features/session/bloc/session_summary_cubit.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = SessionSummaryCubit(
          context.read<SessionRepository>(),
          sessionId,
        );
        unawaited(cubit.load());
        return cubit;
      },
      child: const SessionSummaryView(),
    );
  }
}

extension DurationLabel on AppLocalizations {
  /// `45 min`, `1 h 05 min`.
  String durationText(Duration duration) {
    final minutes = duration.inMinutes;
    return minutes < 60
        ? durationMinutes(minutes)
        : durationHoursMinutes(minutes ~/ 60, minutes % 60);
  }

  String recordLabel(RecordType type) => switch (type) {
    RecordType.maxWeight => recordMaxWeight,
    RecordType.estimatedOneRepMax => recordOneRepMax,
    RecordType.repsAtWeight => recordRepsAtWeight,
    RecordType.sessionVolume => recordSessionVolume,
  };
}

class SessionSummaryView extends StatefulWidget {
  const SessionSummaryView({super.key});

  @override
  State<SessionSummaryView> createState() => _SessionSummaryViewState();
}

class _SessionSummaryViewState extends State<SessionSummaryView> {
  final _notes = TextEditingController();
  bool _notesLoaded = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    final cubit = context.read<SessionSummaryCubit>();
    await cubit.saveNotes(_notes.text);
    if (!mounted) return;
    context.read<SessionBloc>().add(const SessionSummaryClosed());
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<SessionSummaryCubit, SessionSummaryState>(
      listener: (context, state) {
        if (state is SessionSummaryLoaded && !_notesLoaded) {
          _notesLoaded = true;
          _notes.text = state.summary.details.session.notes ?? '';
        }
      },
      builder: (context, state) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(_done());
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.summaryTitle),
            automaticallyImplyLeading: false,
          ),
          body: switch (state) {
            SessionSummaryLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            SessionSummaryNotFound() => Center(child: Text(l10n.notFound)),
            SessionSummaryLoaded(:final summary) => _SummaryBody(
              summary: summary,
              notes: _notes,
            ),
          },
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.all(AppSpacing.lg),
            child: PrimaryActionButton(
              label: l10n.summaryDone,
              onPressed: _done,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.summary, required this.notes});

  final SessionSummary summary;
  final TextEditingController notes;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final unit = context.select<SettingsCubit, WeightUnit>(
      (c) => c.settings.unit,
    );
    final session = summary.details.session;
    final previous = summary.previous;

    String signed(double value, String Function(double) format) =>
        '${value >= 0 ? '+' : '−'}${format(value.abs())}';

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        Text(
          session.name ?? l10n.sessionFree,
          style: theme.textTheme.headlineSmall,
        ),
        Text(
          l10n.longDate(session.startedAt),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: l10n.summaryDuration,
                value: l10n.durationText(summary.duration),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                label: l10n.summaryVolume,
                value: l10n.weightWithUnit(summary.volumeKg, unit),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: StatTile(
                label: l10n.summarySets,
                value: '${summary.setCount}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.summaryRecords.toUpperCase(),
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (summary.records.isEmpty)
          Text(l10n.summaryNoRecords, style: theme.textTheme.bodyMedium)
        else
          for (final record in summary.records)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.exerciseName(record.exercise)),
              subtitle: Text(
                '${l10n.recordLabel(record.type)} · '
                '${record.set.weightKg == null ? '' : '${l10n.weightWithUnit(record.set.weightKg!, unit)} × '}'
                '${record.set.reps ?? ''}',
              ),
              trailing: const PrBadge(),
            ),
        if (session.programDayId != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.summaryVsPrevious.toUpperCase(),
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (previous == null)
            Text(l10n.summaryFirstTime, style: theme.textTheme.bodyMedium)
          else ...[
            Text(
              l10n.summaryVolumeDelta(
                signed(
                  summary.volumeKg - previous.volumeKg,
                  (v) => l10n.weightWithUnit(v, unit),
                ),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              l10n.summaryDurationDelta(
                signed(
                  (summary.duration - previous.duration).inMinutes.toDouble(),
                  (v) => l10n.durationMinutes(v.round()),
                ),
              ),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: notes,
          minLines: 2,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.summaryNote),
        ),
      ],
    );
  }
}
