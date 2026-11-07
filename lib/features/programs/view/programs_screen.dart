import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/widgets/app_shell.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/cards.dart';
import 'package:endelea/core/widgets/dialogs.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:endelea/features/programs/bloc/programs_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProgramsCubit(context.read<ProgramRepository>()),
      child: const ProgramsView(),
    );
  }
}

class ProgramsView extends StatelessWidget {
  const ProgramsView({super.key});

  Future<void> _create(BuildContext context) async {
    final l10n = context.l10n;
    final cubit = context.read<ProgramsCubit>();
    final name = await showTextInputDialog(
      context,
      title: l10n.programNew,
      label: l10n.programName,
      confirmLabel: l10n.create,
    );
    if (name == null || !context.mounted) return;
    final id = await cubit.create(name);
    if (context.mounted) await context.push(AppRoutes.program(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navPrograms),
        actions: [
          IconButton(
            tooltip: l10n.exercisesTitle,
            icon: const Icon(PhosphorIconsRegular.books),
            onPressed: () => context.push(AppRoutes.exercises),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<ProgramsCubit, ProgramsState>(
        builder: (context, state) {
          if (state is ProgramsLoaded && state.programs.isEmpty) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () => _create(context),
            icon: const Icon(PhosphorIconsRegular.plus),
            label: Text(l10n.programNew),
          );
        },
      ),
      body: BlocBuilder<ProgramsCubit, ProgramsState>(
        builder: (context, state) => switch (state) {
          ProgramsLoading() => const Center(child: CircularProgressIndicator()),
          ProgramsError() => Center(child: Text(l10n.errorGeneric)),
          ProgramsLoaded(programs: []) => EmptyState(
            icon: PhosphorIconsDuotone.listChecks,
            title: l10n.programsEmptyTitle,
            message: l10n.programsEmptyMessage,
            action: PrimaryActionButton(
              label: l10n.programNew,
              icon: PhosphorIconsRegular.plus,
              onPressed: () => _create(context),
            ),
          ),
          ProgramsLoaded(:final programs) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.sm,
              AppSpacing.screen,
              96,
            ),
            itemCount: programs.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) =>
                _ProgramItem(summary: programs[index]),
          ),
        },
      ),
    );
  }
}

enum _ProgramAction { rename, duplicate, activate, delete }

class _ProgramItem extends StatelessWidget {
  const _ProgramItem({required this.summary});

  final ProgramSummary summary;

  Future<void> _onAction(BuildContext context, _ProgramAction action) async {
    final l10n = context.l10n;
    final cubit = context.read<ProgramsCubit>();
    final program = summary.program;
    switch (action) {
      case _ProgramAction.rename:
        final name = await showTextInputDialog(
          context,
          title: l10n.programRename,
          label: l10n.programName,
          confirmLabel: l10n.save,
          initialValue: program.name,
        );
        if (name != null) {
          await cubit.rename(
            program.id,
            name,
            description: program.description,
          );
        }
      case _ProgramAction.duplicate:
        await cubit.duplicate(
          program.id,
          name: l10n.programCopyName(program.name),
        );
      case _ProgramAction.activate:
        await cubit.activate(program.id);
      case _ProgramAction.delete:
        final confirmed = await ConfirmSheet.show(
          context,
          title: l10n.programDelete,
          message: l10n.programDeleteMessage(program.name),
          confirmLabel: l10n.delete,
        );
        if (confirmed) await cubit.delete(program.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final program = summary.program;
    final lastSession = summary.lastSessionAt;
    return ProgramCard(
      name: program.name,
      dayCount: summary.dayCount,
      lastSession: lastSession == null ? null : l10n.shortDate(lastSession),
      isActive: program.isActive,
      onTap: () => context.push(AppRoutes.program(program.id)),
      onStart: program.isActive && summary.dayCount > 0
          ? () =>
                StatefulNavigationShell.of(context).goBranch(sessionBranchIndex)
          : null,
      menu: PopupMenuButton<_ProgramAction>(
        tooltip: l10n.programMenu,
        icon: const Icon(PhosphorIconsRegular.dotsThreeVertical),
        onSelected: (action) => _onAction(context, action),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _ProgramAction.rename,
            child: Text(l10n.programRename),
          ),
          PopupMenuItem(
            value: _ProgramAction.duplicate,
            child: Text(l10n.programDuplicate),
          ),
          if (!program.isActive)
            PopupMenuItem(
              value: _ProgramAction.activate,
              child: Text(l10n.programActivate),
            ),
          PopupMenuItem(
            value: _ProgramAction.delete,
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
