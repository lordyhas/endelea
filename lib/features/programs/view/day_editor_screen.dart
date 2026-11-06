import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/cards.dart';
import 'package:endelea/core/widgets/dialogs.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/program_models.dart';
import 'package:endelea/features/programs/bloc/day_editor_cubit.dart';
import 'package:endelea/features/programs/view/targets_sheet.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DayEditorScreen extends StatelessWidget {
  const DayEditorScreen({required this.dayId, super.key});

  final String dayId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DayEditorCubit(
        context.read<ProgramRepository>(),
        dayId,
        defaultRestSeconds: context
            .read<SettingsCubit>()
            .settings
            .defaultRestSeconds,
      ),
      child: const DayEditorView(),
    );
  }
}

class DayEditorView extends StatelessWidget {
  const DayEditorView({super.key});

  Future<void> _addExercises(BuildContext context) async {
    final cubit = context.read<DayEditorCubit>();
    final picked = await context.push<List<Exercise>>(AppRoutes.exercisePicker);
    if (picked == null || picked.isEmpty) return;
    await cubit.addExercises({
      for (final exercise in picked)
        exercise.id: TrackingType.fromKey(exercise.trackingType),
    });
  }

  Future<void> _rename(BuildContext context, ProgramDay day) async {
    final l10n = context.l10n;
    final cubit = context.read<DayEditorCubit>();
    final name = await showTextInputDialog(
      context,
      title: l10n.dayRename,
      label: l10n.dayName,
      confirmLabel: l10n.save,
      initialValue: day.name,
    );
    if (name != null) await cubit.rename(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<DayEditorCubit, DayEditorState>(
      listener: (context, state) {
        if (state is DayEditorNotFound && context.canPop()) context.pop();
      },
      builder: (context, state) {
        final day = switch (state) {
          DayEditorLoaded(:final day) => day,
          _ => null,
        };
        return Scaffold(
          appBar: AppBar(
            title: Text(day?.day.name ?? ''),
            actions: [
              if (day != null)
                IconButton(
                  tooltip: l10n.dayRename,
                  icon: const Icon(PhosphorIconsRegular.pencilSimple),
                  onPressed: () => _rename(context, day.day),
                ),
            ],
          ),
          body: switch (state) {
            DayEditorLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            DayEditorNotFound() => Center(child: Text(l10n.notFound)),
            DayEditorLoaded(:final day) when day.exercises.isEmpty =>
              EmptyState(
                icon: PhosphorIconsDuotone.barbell,
                title: l10n.dayEmptyTitle,
                message: l10n.dayEmptyMessage,
              ),
            DayEditorLoaded(:final day) => _PlannedList(day: day),
          },
          bottomNavigationBar: day == null
              ? null
              : SafeArea(
                  minimum: const EdgeInsets.all(AppSpacing.lg),
                  child: PrimaryActionButton(
                    label: l10n.exerciseAdd,
                    icon: PhosphorIconsRegular.plus,
                    onPressed: () => _addExercises(context),
                  ),
                ),
        );
      },
    );
  }
}

class _PlannedList extends StatelessWidget {
  const _PlannedList({required this.day});

  final ProgramDayDetails day;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      buildDefaultDragHandles: false,
      itemCount: day.exercises.length,
      onReorderItem: (oldIndex, newIndex) =>
          context.read<DayEditorCubit>().move(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final planned = day.exercises[index];
        return _PlannedTile(
          key: ValueKey(planned.plan.id),
          planned: planned,
          index: index,
        );
      },
    );
  }
}

class _PlannedTile extends StatelessWidget {
  const _PlannedTile({required this.planned, required this.index, super.key});

  final PlannedExercise planned;
  final int index;

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<DayEditorCubit>();
    final targets = await TargetsSheet.show(context, planned: planned);
    if (targets != null) await cubit.updateTargets(planned.plan.id, targets);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unit = context.select<SettingsCubit, WeightUnit>(
      (c) => c.settings.unit,
    );
    final plan = planned.plan;
    final exercise = planned.exercise;
    return Dismissible(
      key: ValueKey('dismiss-${plan.id}'),
      direction: DismissDirection.endToStart,
      background: ColoredBox(
        color: Theme.of(context).colorScheme.error,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xl),
            child: Icon(
              PhosphorIconsRegular.trash,
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
        ),
      ),
      onDismissed: (_) => context.read<DayEditorCubit>().remove(plan.id),
      child: ExerciseTile(
        name: l10n.exerciseName(exercise),
        icon: MuscleGroup.fromKey(exercise.muscleGroup).icon,
        subtitle: l10n.targetsSummary(
          trackingType: TrackingType.fromKey(exercise.trackingType),
          sets: plan.targetSets,
          repsMin: plan.targetRepsMin,
          repsMax: plan.targetRepsMax,
          weightKg: plan.targetWeightKg,
          durationSeconds: plan.targetDurationSeconds,
          restSeconds: plan.restSeconds,
          unit: unit,
        ),
        onTap: () => _edit(context),
        trailing: ReorderableDragStartListener(
          index: index,
          child: Tooltip(
            message: l10n.reorder,
            child: const SizedBox.square(
              dimension: AppSizes.minTouch,
              child: Icon(PhosphorIconsRegular.dotsSixVertical),
            ),
          ),
        ),
      ),
    );
  }
}
