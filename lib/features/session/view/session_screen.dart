import 'dart:async';

import 'package:endelea/core/l10n/formatters.dart';
import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/theme/app_typography.dart';
import 'package:endelea/core/utils/clock.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/cards.dart';
import 'package:endelea/core/widgets/dialogs.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/core/widgets/rest_timer.dart';
import 'package:endelea/core/widgets/set_row.dart';
import 'package:endelea/core/widgets/value_stepper.dart';
import 'package:endelea/data/database.dart';
import 'package:endelea/domain/models/exercise_enums.dart';
import 'package:endelea/domain/models/session_models.dart';
import 'package:endelea/domain/session/session_rules.dart';
import 'package:endelea/features/session/bloc/session_bloc.dart';
import 'package:endelea/features/session/view/set_format.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:endelea/features/settings/data/app_settings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// The guided session (PLAN.md §8.6).
class SessionView extends StatefulWidget {
  const SessionView({super.key});

  @override
  State<SessionView> createState() => _SessionViewState();
}

class _SessionViewState extends State<SessionView> {
  /// Set whose values the steppers edit; the current set by default.
  String? _selectedSetId;
  bool _restExpanded = false;

  SessionBloc get _bloc => context.read<SessionBloc>();

  Future<void> _addExercise() async {
    final picked = await context.push<List<Exercise>>(AppRoutes.exercisePicker);
    for (final exercise in picked ?? const <Exercise>[]) {
      _bloc.add(
        ExerciseAdded(exercise.id, TrackingType.fromKey(exercise.trackingType)),
      );
    }
  }

  Future<void> _finish() async {
    final l10n = context.l10n;
    final state = _bloc.state;
    if (state is SessionRunning && !state.isComplete) {
      final confirmed = await ConfirmSheet.show(
        context,
        title: l10n.finishSession,
        message: l10n.sessionFinishMessage,
        confirmLabel: l10n.finishSession,
        destructive: false,
      );
      if (!confirmed) return;
    }
    _bloc.add(const SessionFinishRequested());
  }

  Future<void> _discard() async {
    final l10n = context.l10n;
    final confirmed = await ConfirmSheet.show(
      context,
      title: l10n.sessionDiscard,
      message: l10n.sessionDiscardMessage,
      confirmLabel: l10n.sessionDiscardConfirm,
    );
    if (confirmed) _bloc.add(const SessionDiscarded());
  }

  void _select(int index) {
    setState(() => _selectedSetId = null);
    _bloc.add(ExerciseSelected(index));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionBloc, SessionState>(
      listenWhen: (a, b) =>
          a is SessionRunning &&
          b is SessionRunning &&
          (a.currentExercise?.entry.id != b.currentExercise?.entry.id ||
              a.currentSet?.id != b.currentSet?.id),
      listener: (context, state) => setState(() => _selectedSetId = null),
      buildWhen: (a, b) => b is SessionRunning,
      builder: (context, state) {
        if (state is! SessionRunning) return const SizedBox.shrink();
        final resting = state is SessionResting ? state : null;
        return Scaffold(
          appBar: _SessionAppBar(
            state: state,
            onAddExercise: _addExercise,
            onFinish: _finish,
            onDiscard: _discard,
          ),
          body: Stack(
            children: [
              if (state.details.exercises.isEmpty)
                _EmptySession(onAdd: _addExercise)
              else
                _ExercisePane(
                  state: state,
                  selectedSetId: _selectedSetId,
                  onSelectSet: (id) => setState(() => _selectedSetId = id),
                  onSelectExercise: _select,
                ),
              if (resting != null && _restExpanded)
                Positioned.fill(
                  child: ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Stack(
                      children: [
                        RestTimerFullScreen(
                          remaining: resting.remaining,
                          total: resting.total,
                          nextLabel: _nextLabel(context, resting),
                          onMinus: () => _bloc.add(const RestExtended(-15)),
                          onPlus: () => _bloc.add(const RestExtended(15)),
                          onSkip: () => _bloc.add(const RestSkipped()),
                        ),
                        Positioned(
                          top: AppSpacing.sm,
                          right: AppSpacing.sm,
                          child: IconButton(
                            tooltip: context.l10n.sessionMinimize,
                            icon: const Icon(PhosphorIconsRegular.caretDown),
                            onPressed: () =>
                                setState(() => _restExpanded = false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: state.details.exercises.isEmpty
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.sm,
                      AppSpacing.screen,
                      AppSpacing.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (resting != null && !_restExpanded) ...[
                          RestTimerBar(
                            remaining: resting.remaining,
                            total: resting.total,
                            onMinus: () => _bloc.add(const RestExtended(-15)),
                            onPlus: () => _bloc.add(const RestExtended(15)),
                            onSkip: () => _bloc.add(const RestSkipped()),
                            onExpand: () =>
                                setState(() => _restExpanded = true),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        _PrimaryAction(state: state, onFinish: _finish),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  static String? _nextLabel(BuildContext context, SessionResting state) {
    final exercise = state.currentExercise;
    final setIndex = state.position.setIndex;
    if (exercise == null || setIndex == null) return null;
    final l10n = context.l10n;
    return l10n.nextSetLabel(
      setIndex + 1,
      l10n.exerciseName(exercise.exercise),
    );
  }
}

class _SessionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SessionAppBar({
    required this.state,
    required this.onAddExercise,
    required this.onFinish,
    required this.onDiscard,
  });

  final SessionRunning state;
  final VoidCallback onAddExercise;
  final VoidCallback onFinish;
  final VoidCallback onDiscard;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<SessionBloc>();
    final paused = state is SessionPaused;
    return AppBar(
      leading: IconButton(
        tooltip: l10n.sessionMinimize,
        icon: const Icon(PhosphorIconsRegular.caretDown),
        onPressed: () => StatefulNavigationShell.maybeOf(context)?.goBranch(0),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.details.session.name ?? l10n.sessionFree,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          _SessionClock(session: state.details.session, paused: paused),
        ],
      ),
      actions: [
        if (paused)
          IconButton(
            tooltip: l10n.sessionResume,
            icon: const Icon(PhosphorIconsRegular.play),
            onPressed: () => bloc.add(const SessionResumed()),
          ),
        PopupMenuButton<VoidCallback>(
          tooltip: l10n.sessionMenu,
          icon: const Icon(PhosphorIconsRegular.dotsThreeVertical),
          onSelected: (action) => action(),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: paused
                  ? () => bloc.add(const SessionResumed())
                  : () => bloc.add(const SessionPauseRequested()),
              child: Text(paused ? l10n.sessionResume : l10n.sessionPause),
            ),
            PopupMenuItem(value: onAddExercise, child: Text(l10n.exerciseAdd)),
            if (state.details.exercises.length > 1)
              PopupMenuItem(
                value: () => _ExercisesSheet.show(context),
                child: Text(l10n.sessionExercises),
              ),
            PopupMenuItem(value: onFinish, child: Text(l10n.finishSession)),
            PopupMenuItem(
              value: onDiscard,
              child: Text(
                l10n.sessionDiscard,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Session duration, refreshed every second.
class _SessionClock extends StatefulWidget {
  const _SessionClock({required this.session, required this.paused});

  final WorkoutSession session;
  final bool paused;

  @override
  State<_SessionClock> createState() => _SessionClockState();
}

class _SessionClockState extends State<_SessionClock> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsed = sessionElapsed(widget.session, context.read<Clock>().now());
    final text = formatClock(elapsed);
    return Text(
      widget.paused ? '$text · ${context.l10n.sessionPaused}' : text,
      style: theme.textTheme.bodySmall.tabular,
    );
  }
}

class _EmptySession extends StatelessWidget {
  const _EmptySession({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyState(
      icon: PhosphorIconsDuotone.barbell,
      title: l10n.sessionEmptyTitle,
      message: l10n.sessionEmptyMessage,
      action: PrimaryActionButton(
        label: l10n.exerciseAdd,
        icon: PhosphorIconsRegular.plus,
        onPressed: onAdd,
      ),
    );
  }
}

class _ExercisePane extends StatelessWidget {
  const _ExercisePane({
    required this.state,
    required this.selectedSetId,
    required this.onSelectSet,
    required this.onSelectExercise,
  });

  final SessionRunning state;
  final String? selectedSetId;
  final ValueChanged<String?> onSelectSet;
  final ValueChanged<int> onSelectExercise;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.select<SettingsCubit, AppSettings>(
      (c) => c.settings,
    );
    final exercise = state.currentExercise!;
    final index = state.position.exerciseIndex;
    final count = state.details.exercises.length;
    final columns = SetColumns(l10n, exercise.trackingType, settings.unit);
    final previous = state.previous[exercise.exercise.id] ?? const [];
    final editable = exercise.sets
        .where((s) => s.id == (selectedSetId ?? state.currentSet?.id))
        .firstOrNull;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -300 && index < count - 1) onSelectExercise(index + 1);
        if (velocity > 300 && index > 0) onSelectExercise(index - 1);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.lg,
        ),
        children: [
          _ExerciseHeader(
            exercise: exercise,
            index: index,
            count: count,
            unit: settings.unit,
            onPrevious: index > 0 ? () => onSelectExercise(index - 1) : null,
            onNext: index < count - 1
                ? () => onSelectExercise(index + 1)
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          SetRowHeader(
            valueLabel: columns.valueLabel,
            secondaryLabel: columns.secondaryLabel,
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final (i, set) in exercise.sets.indexed) ...[
            _SetLine(
              set: set,
              number: i + 1,
              columns: columns,
              previous: i < previous.length ? previous[i] : null,
              isCurrent: set.id == state.currentSet?.id,
              isSelected: set.id == editable?.id,
              records: state.records[set.id],
              onTap: () => onSelectSet(set.id),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () =>
                  context.read<SessionBloc>().add(const SetAdded()),
              icon: const Icon(PhosphorIconsRegular.plus),
              label: Text(l10n.addSet),
            ),
          ),
          if (editable != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _SetEditor(
              key: ValueKey(editable.id),
              set: editable,
              type: exercise.trackingType,
              settings: settings,
              canRemove: exercise.sets.length > 1,
            ),
          ] else if (exercise.isDone)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                state.isComplete ? l10n.sessionComplete : l10n.exerciseDone,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class _ExerciseHeader extends StatelessWidget {
  const _ExerciseHeader({
    required this.exercise,
    required this.index,
    required this.count,
    required this.unit,
    required this.onPrevious,
    required this.onNext,
  });

  final SessionExerciseDetails exercise;
  final int index;
  final int count;
  final WeightUnit unit;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  Future<void> _editNotes(BuildContext context) async {
    final l10n = context.l10n;
    final bloc = context.read<SessionBloc>();
    final notes = await showTextInputDialog(
      context,
      title: l10n.exerciseNotes,
      label: l10n.notes,
      confirmLabel: l10n.save,
      initialValue: exercise.entry.notes ?? '',
    );
    if (notes != null) {
      bloc.add(ExerciseNotesChanged(exercise.entry.id, notes));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final entry = exercise.entry;
    final reps = l10n.repsRange(entry.targetRepsMin, entry.targetRepsMax);
    final target = reps == null
        ? null
        : l10n.setsTimesReps(exercise.sets.length, reps);
    final notes = entry.notes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.previousExercise,
              onPressed: onPrevious,
              icon: const Icon(PhosphorIconsRegular.caretLeft),
            ),
            Expanded(
              child: Text(
                l10n.exerciseName(exercise.exercise),
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              tooltip: l10n.nextExercise,
              onPressed: onNext,
              icon: const Icon(PhosphorIconsRegular.caretRight),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                [
                  l10n.sessionExerciseOf(index + 1, count),
                  if (target != null) l10n.sessionTarget(target),
                ].join(' · '),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              tooltip: l10n.exerciseNotes,
              onPressed: () => _editNotes(context),
              icon: Icon(
                PhosphorIconsRegular.notePencil,
                size: AppSizes.iconDense,
                color: notes == null
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        if (notes != null)
          Text(
            notes,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}

class _SetLine extends StatelessWidget {
  const _SetLine({
    required this.set,
    required this.number,
    required this.columns,
    required this.previous,
    required this.isCurrent,
    required this.isSelected,
    required this.records,
    required this.onTap,
  });

  final SetEntry set;
  final int number;
  final SetColumns columns;
  final PerformedSet? previous;
  final bool isCurrent;
  final bool isSelected;
  final Set<Object>? records;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SessionBloc>();
    final done = set.completedAt != null;
    final row = SetRow(
      index: number,
      isWarmup: set.isWarmup,
      state: done
          ? SetRowState.done
          : (isCurrent || isSelected)
          ? SetRowState.current
          : SetRowState.pending,
      previous: columns.previous(previous),
      value: columns.value(
        weightKg: set.weightKg,
        reps: set.reps,
        durationSeconds: set.durationSeconds,
        distanceMeters: set.distanceMeters,
      ),
      secondary: columns.secondary(
        reps: set.reps,
        durationSeconds: set.durationSeconds,
      ),
      onTap: onTap,
      onCheck: () =>
          bloc.add(done ? SetUncompleted(set.id) : SetCompleted(setId: set.id)),
    );
    final records = this.records;
    if (records == null || records.isEmpty) return row;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        row,
        const Positioned(top: -8, right: 64, child: PrBadge()),
      ],
    );
  }
}

/// Steppers of the selected set.
class _SetEditor extends StatelessWidget {
  const _SetEditor({
    required this.set,
    required this.type,
    required this.settings,
    required this.canRemove,
    super.key,
  });

  final SetEntry set;
  final TrackingType type;
  final AppSettings settings;
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<SessionBloc>();
    final values = valuesOf(set);
    void update(SetValues next) => bloc.add(SetValuesChanged(set.id, next));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (type.usesWeight) ...[
          WeightStepper(
            weightKg: set.weightKg ?? 0,
            unit: settings.unit,
            step: settings.effectiveWeightStep,
            onChanged: (kg) => update(
              SetValues(
                weightKg: kg,
                reps: values.reps,
                isWarmup: values.isWarmup,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (type.usesReps)
          RepsStepper(
            reps: set.reps ?? 0,
            onChanged: (reps) => update(
              SetValues(
                weightKg: values.weightKg,
                reps: reps,
                isWarmup: values.isWarmup,
              ),
            ),
          ),
        if (type.usesDistance) ...[
          ValueStepper(
            value: (set.distanceMeters ?? 0) / 1000,
            step: 0.1,
            decimals: 2,
            label: l10n.distanceLabel,
            unitLabel: l10n.setColumnDistance,
            semanticUnit: l10n.setColumnDistance,
            onChanged: (km) => update(
              values.copyWith(distanceMeters: (km * 1000).roundToDouble()),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (type.usesDuration)
          DurationStepper(
            seconds: set.durationSeconds ?? 0,
            onChanged: (seconds) =>
                update(values.copyWith(durationSeconds: seconds)),
          ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            FilterChip(
              label: Text(l10n.markWarmup),
              selected: set.isWarmup,
              onSelected: (warmup) => update(
                SetValues(
                  weightKg: values.weightKg,
                  reps: values.reps,
                  durationSeconds: values.durationSeconds,
                  distanceMeters: values.distanceMeters,
                  isWarmup: warmup,
                ),
              ),
            ),
            const Spacer(),
            if (canRemove)
              TextButton.icon(
                onPressed: () => bloc.add(SetRemoved(set.id)),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                icon: const Icon(PhosphorIconsRegular.trash),
                label: Text(l10n.removeSet),
              ),
          ],
        ),
      ],
    );
  }
}

/// "Complete set" → "Skip rest" → "Next exercise" → "Finish workout".
class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.state, required this.onFinish});

  final SessionRunning state;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<SessionBloc>();
    final state = this.state;
    final (String label, VoidCallback action) = switch (state) {
      SessionPaused() => (
        l10n.sessionResume,
        () => bloc.add(const SessionResumed()),
      ),
      SessionResting() => (
        l10n.restSkipAction,
        () => bloc.add(const RestSkipped()),
      ),
      _ when state.currentSet != null => (
        l10n.setValidate,
        () => bloc.add(const SetCompleted()),
      ),
      _ when !state.isComplete => (
        l10n.nextExercise,
        () => bloc.add(const ExerciseSkipped()),
      ),
      _ => (l10n.finishSession, onFinish),
    };
    return PrimaryActionButton(label: label, onPressed: action);
  }
}

/// Reorder the exercises of the session.
class _ExercisesSheet extends StatelessWidget {
  const _ExercisesSheet();

  static Future<void> show(BuildContext context) {
    final bloc = context.read<SessionBloc>();
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) =>
          BlocProvider.value(value: bloc, child: const _ExercisesSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state is! SessionRunning) return const SizedBox.shrink();
        final exercises = state.details.exercises;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: AppSpacing.screenPadding,
                child: Text(
                  l10n.sessionExercises,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Flexible(
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  buildDefaultDragHandles: false,
                  itemCount: exercises.length,
                  onReorderItem: (oldIndex, newIndex) => context
                      .read<SessionBloc>()
                      .add(ExercisesReordered(oldIndex, newIndex)),
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    final done = exercise.sets
                        .where((s) => s.completedAt != null)
                        .length;
                    return ListTile(
                      key: ValueKey(exercise.entry.id),
                      title: Text(l10n.exerciseName(exercise.exercise)),
                      subtitle: Text('$done / ${exercise.sets.length}'),
                      selected: index == state.position.exerciseIndex,
                      onTap: () {
                        context.read<SessionBloc>().add(
                          ExerciseSelected(index),
                        );
                        Navigator.of(context).pop();
                      },
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
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}
