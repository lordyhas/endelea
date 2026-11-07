import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/l10n/labels.dart';
import 'package:endelea/core/theme/app_colors.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/theme/app_typography.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:endelea/features/session/bloc/session_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Persistent bar while a session runs on another tab: exercise and rest
/// left. Tapping it goes back to the session.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        if (state is! SessionRunning) return const SizedBox.shrink();
        final l10n = context.l10n;
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final exercise = state.currentExercise;
        final title = exercise == null
            ? state.details.session.name ?? l10n.sessionFree
            : l10n.exerciseName(exercise.exercise);
        final resting = state is SessionResting ? state : null;
        final subtitle = switch (state) {
          SessionPaused() => l10n.sessionPaused,
          SessionResting(:final remaining) => l10n.restRemaining(
            formatClock(remaining),
          ),
          _ => l10n.sessionInProgress,
        };

        return Material(
          color: AppColors.of(context).surfaceHigh,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (resting != null)
                  LinearProgressIndicator(
                    value: resting.total.inMilliseconds == 0
                        ? 0
                        : resting.remaining.inMilliseconds /
                              resting.total.inMilliseconds,
                    color: scheme.secondary,
                    minHeight: 3,
                  ),
                SizedBox(
                  height: AppSizes.sessionTouch,
                  child: Padding(
                    padding: AppSpacing.screenPadding,
                    child: Row(
                      children: [
                        Icon(
                          resting == null
                              ? PhosphorIconsRegular.barbell
                              : PhosphorIconsRegular.timer,
                          color: resting == null
                              ? scheme.primary
                              : scheme.secondary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodySmall.tabular,
                              ),
                            ],
                          ),
                        ),
                        const Icon(PhosphorIconsRegular.caretUp),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
