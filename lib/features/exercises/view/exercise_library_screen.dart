import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/cards.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/data/repositories/exercise_repository.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/features/exercises/bloc/exercises_cubit.dart';
import 'package:endelea/features/exercises/view/exercise_form_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Exercise library. In [pick] mode it is a multi-select picker that pops
/// the selected exercises, in selection order.
class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({this.pick = false, super.key});

  final bool pick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (context) => ExercisesCubit(
        context.read<ExerciseRepository>(),
        nameOf: l10n.exerciseName,
      ),
      child: ExerciseLibraryView(pick: pick),
    );
  }
}

class ExerciseLibraryView extends StatefulWidget {
  const ExerciseLibraryView({required this.pick, super.key});

  final bool pick;

  @override
  State<ExerciseLibraryView> createState() => _ExerciseLibraryViewState();
}

class _ExerciseLibraryViewState extends State<ExerciseLibraryView> {
  final _selected = <Exercise>[];
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggle(Exercise exercise) {
    setState(() {
      if (!_selected.remove(exercise)) _selected.add(exercise);
    });
  }

  Future<void> _create() async {
    final cubit = context.read<ExercisesCubit>();
    final result = await ExerciseFormSheet.show(
      context,
      initialName: _search.text.trim(),
    );
    if (result == null) return;
    final created = await cubit.create(
      name: result.name,
      muscleGroup: result.muscleGroup,
      equipment: result.equipment,
      trackingType: result.trackingType,
    );
    _search.clear();
    cubit.clearFilters();
    if (widget.pick && created != null && mounted) {
      setState(() => _selected.add(created));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exercisesTitle),
        actions: [
          IconButton(
            tooltip: l10n.exerciseCreate,
            icon: const Icon(PhosphorIconsRegular.plus),
            onPressed: _create,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              0,
              AppSpacing.screen,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _search,
              onChanged: context.read<ExercisesCubit>().search,
              decoration: InputDecoration(
                hintText: l10n.exerciseSearch,
                prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass),
              ),
            ),
          ),
          const _Filters(),
          Expanded(
            child: BlocBuilder<ExercisesCubit, ExercisesState>(
              builder: (context, state) => switch (state) {
                ExercisesLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ExercisesLoaded(visible: []) => EmptyState(
                  icon: PhosphorIconsDuotone.magnifyingGlass,
                  title: l10n.exercisesNoResultTitle,
                  message: l10n.exercisesNoResultMessage,
                  action: SecondaryButton(
                    label: l10n.exerciseCreate,
                    icon: PhosphorIconsRegular.plus,
                    onPressed: _create,
                  ),
                ),
                ExercisesLoaded(:final visible) => ListView.builder(
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final exercise = visible[index];
                    final group = MuscleGroup.fromKey(exercise.muscleGroup);
                    final equipment = Equipment.fromKey(exercise.equipment);
                    return ExerciseTile(
                      name: l10n.exerciseName(exercise),
                      icon: group.icon,
                      subtitle: [
                        if (group != null) l10n.muscleGroup(group),
                        if (equipment != null) l10n.equipment(equipment),
                        if (exercise.isCustom) l10n.exerciseCustom,
                      ].join(' · '),
                      selected: widget.pick && _selected.contains(exercise),
                      onTap: widget.pick
                          ? () => _toggle(exercise)
                          : () => context.push(AppRoutes.exercise(exercise.id)),
                    );
                  },
                ),
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.pick
          ? SafeArea(
              minimum: const EdgeInsets.all(AppSpacing.lg),
              child: PrimaryActionButton(
                label: l10n.exerciseAddCount(_selected.length),
                onPressed: _selected.isEmpty
                    ? null
                    : () => context.pop(List<Exercise>.of(_selected)),
              ),
            )
          : null,
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ExercisesCubit>();
    return BlocBuilder<ExercisesCubit, ExercisesState>(
      buildWhen: (a, b) =>
          a is! ExercisesLoaded ||
          b is! ExercisesLoaded ||
          a.muscleGroups != b.muscleGroups ||
          a.equipment != b.equipment,
      builder: (context, state) {
        final muscles = state is ExercisesLoaded
            ? state.muscleGroups
            : const <MuscleGroup>{};
        final equipment = state is ExercisesLoaded
            ? state.equipment
            : const <Equipment>{};
        Widget row(List<Widget> chips) => SizedBox(
          height: AppSizes.minTouch,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.screenPadding,
            itemCount: chips.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, index) => Center(child: chips[index]),
          ),
        );
        return Column(
          children: [
            row([
              for (final group in MuscleGroup.values)
                FilterChip(
                  label: Text(l10n.muscleGroup(group)),
                  selected: muscles.contains(group),
                  onSelected: (_) => cubit.toggleMuscleGroup(group),
                ),
            ]),
            row([
              for (final item in Equipment.values)
                FilterChip(
                  label: Text(l10n.equipment(item)),
                  selected: equipment.contains(item),
                  onSelected: (_) => cubit.toggleEquipment(item),
                ),
            ]),
            const SizedBox(height: AppSpacing.xs),
          ],
        );
      },
    );
  }
}
