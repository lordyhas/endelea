import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/theme/app_colors.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Duotone icon, title, sentence and an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final PhosphorDuotoneIconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final action = this.action;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorDuotoneIcon(
              icon,
              size: AppSizes.iconEmpty,
              color: scheme.primary,
              secondaryOpacity: 0.3,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom confirmation sheet; destructive actions are shown in `error`.
class ConfirmSheet extends StatelessWidget {
  const ConfirmSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.destructive = true,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final bool destructive;

  /// Returns true when the user confirms.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = true,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => ConfirmSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: AppSizes.sessionTouch,
              child: FilledButton(
                style: destructive
                    ? FilledButton.styleFrom(
                        backgroundColor: scheme.error,
                        foregroundColor: scheme.onError,
                      )
                    : null,
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: context.l10n.cancel,
              outlined: true,
              expand: true,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

enum SyncStatus { disabled, upToDate, syncing, error }

/// State of the cloud sync.
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({required this.status, this.onTap, super.key});

  final SyncStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = AppColors.of(context);
    final (icon, label, color) = switch (status) {
      SyncStatus.disabled => (
        PhosphorIconsRegular.cloudSlash,
        l10n.syncDisabled,
        scheme.onSurfaceVariant,
      ),
      SyncStatus.upToDate => (
        PhosphorIconsRegular.cloudCheck,
        l10n.syncUpToDate,
        colors.success,
      ),
      SyncStatus.syncing => (
        PhosphorIconsRegular.cloudArrowUp,
        l10n.syncInProgress,
        scheme.secondary,
      ),
      SyncStatus.error => (
        PhosphorIconsRegular.cloudWarning,
        l10n.syncError,
        scheme.error,
      ),
    };
    return Semantics(
      button: onTap != null,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: colors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.sheet),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 36),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: AppSizes.iconDense, color: color),
                    const SizedBox(width: AppSpacing.xs),
                    Text(label, style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
