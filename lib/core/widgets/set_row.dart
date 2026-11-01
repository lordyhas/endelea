import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/theme/app_colors.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/theme/app_typography.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum SetRowState { pending, current, done }

/// Column header of a [SetRow] table: Set · Previous · kg · Reps · ✓.
class SetRowHeader extends StatelessWidget {
  const SetRowHeader({
    required this.valueLabel,
    required this.secondaryLabel,
    super.key,
  });

  /// "kg", "lb" or "Time".
  final String valueLabel;

  /// "Reps" or "km".
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final style = Theme.of(context).textTheme.labelSmall;
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: _SetRowLayout.index,
              child: Text(l10n.setColumnSet.toUpperCase(), style: style),
            ),
            Expanded(
              flex: 3,
              child: Text(l10n.setColumnPrevious.toUpperCase(), style: style),
            ),
            Expanded(
              flex: 2,
              child: Text(
                valueLabel.toUpperCase(),
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                (secondaryLabel ?? '').toUpperCase(),
                style: style,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: _SetRowLayout.check),
          ],
        ),
      ),
    );
  }
}

abstract final class _SetRowLayout {
  static const double index = 44;
  static const double check = AppSizes.sessionTouch;
}

/// One set: index, previous value, value, reps, check.
///
/// States: pending (dimmed), current (primary border), done (green
/// background and check), warm-up (label "W"). Done is never shown by color
/// alone: the check icon is filled.
class SetRow extends StatelessWidget {
  const SetRow({
    required this.index,
    required this.state,
    required this.value,
    this.secondary,
    this.previous,
    this.isWarmup = false,
    this.onCheck,
    this.onTap,
    super.key,
  });

  /// 1-based set number.
  final int index;
  final SetRowState state;
  final String value;
  final String? secondary;
  final String? previous;
  final bool isWarmup;
  final VoidCallback? onCheck;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final done = state == SetRowState.done;
    final current = state == SetRowState.current;

    final background = done ? colors.successContainer : colors.surfaceHigh;
    final foreground = state == SetRowState.pending
        ? scheme.onSurfaceVariant
        : scheme.onSurface;
    final numbers = theme.textTheme.titleMedium.tabular?.copyWith(
      color: foreground,
    );
    final stateLabel = switch (state) {
      SetRowState.pending => l10n.setPending,
      SetRowState.current => l10n.setCurrent,
      SetRowState.done => l10n.setDone,
    };

    return Semantics(
      label: [
        '${l10n.setColumnSet} $index',
        if (isWarmup) l10n.warmupLabel,
        value,
        ?secondary,
        stateLabel,
      ].join(', '),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          side: current
              ? BorderSide(color: scheme.primary, width: 2)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizes.sessionTouch),
            child: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: Row(
                children: [
                  SizedBox(
                    width: _SetRowLayout.index,
                    child: ExcludeSemantics(
                      child: isWarmup
                          ? Text(
                              l10n.warmupShort,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: scheme.secondary,
                              ),
                            )
                          : Text('$index', style: numbers),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ExcludeSemantics(
                      child: Text(
                        previous ?? '–',
                        style: theme.textTheme.bodyMedium.tabular?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ExcludeSemantics(
                      child: Text(
                        value,
                        style: numbers,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ExcludeSemantics(
                      child: Text(
                        secondary ?? '',
                        style: numbers,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  _CheckButton(done: done, onPressed: onCheck),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton({required this.done, required this.onPressed});

  final bool done;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: _SetRowLayout.check,
      child: IconButton(
        onPressed: onPressed,
        tooltip: context.l10n.setDone,
        icon: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: done ? colors.success : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: done ? null : Border.all(color: scheme.outline, width: 2),
          ),
          child: Icon(
            PhosphorIconsRegular.check,
            size: AppSizes.iconDense,
            color: done ? colors.onSuccess : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
