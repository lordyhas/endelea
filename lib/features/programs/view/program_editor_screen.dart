import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/dialogs.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:endelea/features/programs/bloc/program_editor_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProgramEditorScreen extends StatelessWidget {
  const ProgramEditorScreen({required this.programId, super.key});

  final String programId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProgramEditorCubit(context.read<ProgramRepository>(), programId),
      child: const ProgramEditorView(),
    );
  }
}

class ProgramEditorView extends StatelessWidget {
  const ProgramEditorView({super.key});

  /// "Day A", "Day B"… after the existing days.
  static String _nextDayName(AppLocalizations l10n, int dayCount) {
    final letter = String.fromCharCode('A'.codeUnitAt(0) + dayCount % 26);
    return l10n.dayDefaultName(letter);
  }

  Future<void> _addDay(BuildContext context, int dayCount) async {
    final l10n = context.l10n;
    final cubit = context.read<ProgramEditorCubit>();
    final name = await showTextInputDialog(
      context,
      title: l10n.dayAdd,
      label: l10n.dayName,
      confirmLabel: l10n.create,
      initialValue: _nextDayName(l10n, dayCount),
    );
    if (name == null || !context.mounted) return;
    final dayId = await cubit.addDay(name);
    if (context.mounted) {
      await context.push(AppRoutes.programDay(cubit.programId, dayId));
    }
  }

  Future<void> _editProgram(
    BuildContext context,
    ProgramDetails details,
  ) async {
    final l10n = context.l10n;
    final cubit = context.read<ProgramEditorCubit>();
    final name = await showTextInputDialog(
      context,
      title: l10n.programRename,
      label: l10n.programName,
      confirmLabel: l10n.save,
      initialValue: details.program.name,
    );
    if (name != null) {
      await cubit.update(name: name, description: details.program.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<ProgramEditorCubit, ProgramEditorState>(
      listener: (context, state) {
        if (state is ProgramEditorNotFound && context.canPop()) context.pop();
      },
      builder: (context, state) {
        final details = switch (state) {
          ProgramEditorLoaded(:final details) => details,
          _ => null,
        };
        return Scaffold(
          appBar: AppBar(
            title: Text(details?.program.name ?? ''),
            actions: [
              if (details != null)
                IconButton(
                  tooltip: l10n.programRename,
                  icon: const Icon(PhosphorIconsRegular.pencilSimple),
                  onPressed: () => _editProgram(context, details),
                ),
            ],
          ),
          floatingActionButton: details == null || details.days.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _addDay(context, details.days.length),
                  icon: const Icon(PhosphorIconsRegular.plus),
                  label: Text(l10n.dayAdd),
                ),
          body: switch (state) {
            ProgramEditorLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ProgramEditorNotFound() => Center(child: Text(l10n.notFound)),
            ProgramEditorLoaded(:final details) when details.days.isEmpty =>
              EmptyState(
                icon: PhosphorIconsDuotone.calendarBlank,
                title: l10n.daysEmptyTitle,
                message: l10n.daysEmptyMessage,
                action: PrimaryActionButton(
                  label: l10n.dayAdd,
                  icon: PhosphorIconsRegular.plus,
                  onPressed: () => _addDay(context, 0),
                ),
              ),
            ProgramEditorLoaded(:final details) => _DayList(details: details),
          },
        );
      },
    );
  }
}

class _DayList extends StatelessWidget {
  const _DayList({required this.details});

  final ProgramDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final description = details.program.description;
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      buildDefaultDragHandles: false,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          AppSpacing.sm,
          AppSpacing.screen,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description != null) ...[
              Text(description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              l10n.programDaysTitle.toUpperCase(),
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
      itemCount: details.days.length,
      onReorderItem: (oldIndex, newIndex) =>
          context.read<ProgramEditorCubit>().moveDay(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final summary = details.days[index];
        return _DayTile(
          key: ValueKey(summary.day.id),
          summary: summary,
          index: index,
          programId: details.program.id,
        );
      },
    );
  }
}

enum _DayAction { rename, delete }

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.summary,
    required this.index,
    required this.programId,
    super.key,
  });

  final ProgramDaySummary summary;
  final int index;
  final String programId;

  Future<void> _onAction(BuildContext context, _DayAction action) async {
    final l10n = context.l10n;
    final cubit = context.read<ProgramEditorCubit>();
    final day = summary.day;
    switch (action) {
      case _DayAction.rename:
        final name = await showTextInputDialog(
          context,
          title: l10n.dayRename,
          label: l10n.dayName,
          confirmLabel: l10n.save,
          initialValue: day.name,
        );
        if (name != null) await cubit.renameDay(day.id, name);
      case _DayAction.delete:
        final confirmed = await ConfirmSheet.show(
          context,
          title: l10n.dayDelete,
          message: l10n.dayDeleteMessage(day.name),
          confirmLabel: l10n.delete,
        );
        if (confirmed) await cubit.deleteDay(day.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      onTap: () =>
          context.push(AppRoutes.programDay(programId, summary.day.id)),
      leading: ReorderableDragStartListener(
        index: index,
        child: Tooltip(
          message: l10n.reorder,
          child: const SizedBox.square(
            dimension: AppSizes.minTouch,
            child: Icon(PhosphorIconsRegular.dotsSixVertical),
          ),
        ),
      ),
      title: Text(summary.day.name),
      subtitle: Text(l10n.dayExercises(summary.exerciseCount)),
      trailing: PopupMenuButton<_DayAction>(
        tooltip: l10n.more,
        icon: const Icon(PhosphorIconsRegular.dotsThreeVertical),
        onSelected: (action) => _onAction(context, action),
        itemBuilder: (context) => [
          PopupMenuItem(value: _DayAction.rename, child: Text(l10n.dayRename)),
          PopupMenuItem(
            value: _DayAction.delete,
            child: Text(
              l10n.dayDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
