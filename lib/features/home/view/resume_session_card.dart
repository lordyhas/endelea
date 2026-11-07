import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/widgets/app_shell.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/features/session/bloc/session_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// "Resume workout", shown first on the home screen while a session is in
/// progress (PLAN.md §5.1).
class ResumeSessionCard extends StatelessWidget {
  const ResumeSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state is! SessionRunning) return const SizedBox.shrink();
        final l10n = context.l10n;
        final theme = Theme.of(context);
        final done = state.details.exercises.fold<int>(
          0,
          (sum, e) => sum + e.sets.where((s) => s.completedAt != null).length,
        );
        final total = state.details.exercises.fold<int>(
          0,
          (sum, e) => sum + e.sets.length,
        );
        final exercise = state.currentExercise;
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
            side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.sessionInProgress.toUpperCase(),
                  style: theme.textTheme.labelSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  state.details.session.name ?? l10n.sessionFree,
                  style: theme.textTheme.titleLarge,
                ),
                Text(
                  [
                    if (exercise != null) l10n.exerciseName(exercise.exercise),
                    '$done / $total',
                  ].join(' · '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryActionButton(
                  label: l10n.resumeSession,
                  icon: PhosphorIconsRegular.play,
                  onPressed: () =>
                      StatefulNavigationShell.of(context)
                          .goBranch(sessionBranchIndex),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
