import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/theme/app_colors.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/theme/app_typography.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// List row for an exercise: muscle group icon, name, equipment.
class ExerciseTile extends StatelessWidget {
  const ExerciseTile({
    required this.name,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
    this.selected = false,
    super.key,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      selected: selected,
      selectedColor: scheme.onSurface,
      selectedTileColor: AppColors.of(context).surfaceHigh,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.of(context).surfaceHighest,
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        child: Icon(icon, size: AppSizes.iconDense, color: scheme.onSurface),
      ),
      title: Text(name),
      subtitle: Text(subtitle),
      trailing:
          trailing ??
          (selected
              ? Icon(PhosphorIconsRegular.check, color: scheme.primary)
              : null),
    );
  }
}

/// Card of a program: name, number of days, last session, "Start".
class ProgramCard extends StatelessWidget {
  const ProgramCard({
    required this.name,
    required this.dayCount,
    required this.lastSession,
    required this.isActive,
    this.onTap,
    this.onStart,
    this.menu,
    super.key,
  });

  final String name;
  final int dayCount;

  /// Formatted date of the last session, or null if never started.
  final String? lastSession;
  final bool isActive;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final Widget? menu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lastSession = this.lastSession;
    final menu = this.menu;
    final onStart = this.onStart;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: isActive
            ? BorderSide(color: scheme.primary, width: 1.5)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(name, style: theme.textTheme.titleMedium),
                  ),
                  if (isActive) _ActiveBadge(label: l10n.programActive),
                  ?menu,
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                [
                  l10n.programDays(dayCount),
                  if (lastSession != null)
                    l10n.programLastSession(lastSession)
                  else
                    l10n.programNeverStarted,
                ].join(' · '),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (onStart != null) ...[
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: SecondaryButton(
                    label: l10n.start,
                    icon: PhosphorIconsRegular.play,
                    onPressed: onStart,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.primary),
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: scheme.primary),
      ),
    );
  }
}

/// Small indicator: label and number.
class StatTile extends StatelessWidget {
  const StatTile({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(value, style: theme.textTheme.titleLarge.tabular),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Green pill with a trophy: personal record.
class PrBadge extends StatelessWidget {
  const PrBadge({this.label, super.key});

  /// Defaults to "Record".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colors.success,
        borderRadius: BorderRadius.circular(AppRadius.sheet),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsFill.trophy, size: 14, color: colors.onSuccess),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label ?? context.l10n.personalRecord,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: colors.onSuccess),
          ),
        ],
      ),
    );
  }
}
