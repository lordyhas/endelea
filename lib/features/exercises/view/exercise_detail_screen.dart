import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/features/exercises/bloc/exercise_detail_cubit.dart';
import 'package:endelea/features/exercises/view/exercise_form_sheet.dart';
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
      create: (context) =>
          ExerciseDetailCubit(context.read<ExerciseRepository>(), exerciseId),
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
          body: exercise == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  children: [_ExerciseInfo(exercise: exercise)],
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
