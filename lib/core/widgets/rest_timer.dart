import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/theme/app_colors.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/theme/app_typography.dart';
import 'package:endelea/core/utils/units.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Compact rest timer: ochre icon, progress, time left, −15 / +15 / Skip.
class RestTimerBar extends StatelessWidget {
  const RestTimerBar({
    required this.remaining,
    required this.total,
    required this.onMinus,
    required this.onPlus,
    required this.onSkip,
    this.onExpand,
    super.key,
  });

  final Duration remaining;
  final Duration total;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onSkip;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final time = formatClock(remaining);

    return Material(
      color: AppColors.of(context).surfaceHigh,
      borderRadius: BorderRadius.circular(AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: _progress(remaining, total),
            color: scheme.secondary,
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.timer, color: scheme.secondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    label: l10n.restRemaining(time),
                    child: ExcludeSemantics(
                      child: InkWell(
                        onTap: onExpand,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Text(
                            time,
                            style: theme.textTheme.titleLarge.tabular?.copyWith(
                              color: scheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _TimerButton(label: l10n.restMinus15, onPressed: onMinus),
                _TimerButton(label: l10n.restPlus15, onPressed: onPlus),
                _TimerButton(label: l10n.restSkip, onPressed: onSkip),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  const _TimerButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(AppSizes.sessionTouch, AppSizes.sessionTouch),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      child: Text(label),
    );
  }
}

/// Full-screen rest timer with large digits.
class RestTimerFullScreen extends StatelessWidget {
  const RestTimerFullScreen({
    required this.remaining,
    required this.total,
    required this.onMinus,
    required this.onPlus,
    required this.onSkip,
    this.nextLabel,
    super.key,
  });

  final Duration remaining;
  final Duration total;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onSkip;

  /// What comes next, e.g. "Set 3 · Bench press".
  final String? nextLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final time = formatClock(remaining);
    final nextLabel = this.nextLabel;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.restTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xl),
          SizedBox.square(
            dimension: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: _progress(remaining, total),
                  strokeWidth: 8,
                  color: scheme.secondary,
                  backgroundColor: AppColors.of(context).surfaceHighest,
                ),
                Center(
                  child: Semantics(
                    liveRegion: true,
                    label: l10n.restRemaining(time),
                    child: ExcludeSemantics(
                      child: Text(
                        time,
                        style: theme.textTheme.displayLarge.tabular?.copyWith(
                          color: scheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (nextLabel != null) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              nextLabel,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimerButton(label: l10n.restMinus15, onPressed: onMinus),
              const SizedBox(width: AppSpacing.lg),
              _TimerButton(label: l10n.restPlus15, onPressed: onPlus),
              const SizedBox(width: AppSpacing.lg),
              _TimerButton(label: l10n.restSkip, onPressed: onSkip),
            ],
          ),
        ],
      ),
    );
  }
}

double _progress(Duration remaining, Duration total) {
  if (total.inMilliseconds <= 0) return 0;
  return (remaining.inMilliseconds / total.inMilliseconds).clamp(0, 1);
}
