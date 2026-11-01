import 'package:endelea/core/theme/app_colors.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Filled primary button, 56 high, full width. One per screen.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return SizedBox(
      width: double.infinity,
      height: AppSizes.sessionTouch,
      child: icon == null
          ? FilledButton(onPressed: onPressed, child: Text(label))
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            ),
    );
  }
}

/// Tonal (`surfaceHighest`) or outlined secondary button.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.expand = false,
    this.destructive = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final bool expand;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = destructive ? scheme.error : scheme.onSurface;
    final style = outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: foreground,
            minimumSize: const Size(AppSizes.minTouch, AppSizes.minTouch),
          )
        : FilledButton.styleFrom(
            backgroundColor: AppColors.of(context).surfaceHighest,
            foregroundColor: foreground,
            minimumSize: const Size(AppSizes.minTouch, AppSizes.minTouch),
            textStyle: Theme.of(context).textTheme.labelLarge,
          );
    final icon = this.icon;
    final Widget button;
    if (outlined) {
      button = icon == null
          ? OutlinedButton(
              onPressed: onPressed,
              style: style,
              child: Text(label),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(icon, size: AppSizes.iconDense),
              label: Text(label),
            );
    } else {
      button = icon == null
          ? FilledButton(onPressed: onPressed, style: style, child: Text(label))
          : FilledButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(icon, size: AppSizes.iconDense),
              label: Text(label),
            );
    }
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
