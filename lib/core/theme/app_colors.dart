import 'package:material_ui/material_ui.dart';

/// Raw "Savane" palette values (PLAN.md §6.1).
///
/// Only the theme layer reads these. Widgets use
/// `Theme.of(context).colorScheme` or the [AppColors] extension.
abstract final class SavanePalette {
  static const seed = Color(0xFFE2683C);

  static const darkBackground = Color(0xFF141210);
  static const darkSurface = Color(0xFF1C1815);
  static const darkSurfaceHigh = Color(0xFF221D19);
  static const darkSurfaceHighest = Color(0xFF2D2621);
  static const darkOutline = Color(0xFF3A332E);
  static const darkOnSurface = Color(0xFFF3EEE8);
  static const darkOnSurfaceVariant = Color(0xFFA89E94);
  static const darkPrimary = Color(0xFFE2683C);
  static const darkOnPrimary = Color(0xFF1A0D06);
  static const darkSecondary = Color(0xFFE8A33D);
  static const darkSuccess = Color(0xFF6FBF73);
  static const darkError = Color(0xFFE5534B);

  static const lightBackground = Color(0xFFFAF7F4);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceHigh = Color(0xFFF3EEE9);
  static const lightSurfaceHighest = Color(0xFFE9E2DB);
  static const lightOutline = Color(0xFFD8CFC6);
  static const lightOnSurface = Color(0xFF1F1A16);
  static const lightOnSurfaceVariant = Color(0xFF6B6158);
  static const lightPrimary = Color(0xFFC4532A);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightSecondary = Color(0xFFB9791A);
  static const lightSuccess = Color(0xFF3E8E43);
  static const lightError = Color(0xFFC23A33);
}

/// Theme tokens that have no slot in [ColorScheme].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.surfaceHighest,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
  });

  static const dark = AppColors(
    background: SavanePalette.darkBackground,
    surface: SavanePalette.darkSurface,
    surfaceHigh: SavanePalette.darkSurfaceHigh,
    surfaceHighest: SavanePalette.darkSurfaceHighest,
    success: SavanePalette.darkSuccess,
    onSuccess: SavanePalette.darkBackground,
    successContainer: Color(0xFF1E2A1C),
  );

  static const light = AppColors(
    background: SavanePalette.lightBackground,
    surface: SavanePalette.lightSurface,
    surfaceHigh: SavanePalette.lightSurfaceHigh,
    surfaceHighest: SavanePalette.lightSurfaceHighest,
    success: SavanePalette.lightSuccess,
    onSuccess: SavanePalette.lightSurface,
    successContainer: Color(0xFFE3F1E2),
  );

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color surfaceHighest;

  /// Validated set, personal record.
  final Color success;
  final Color onSuccess;

  /// Background of a validated set row.
  final Color successContainer;

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? surfaceHighest,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      surfaceHighest: surfaceHighest ?? this.surfaceHighest,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      surfaceHighest: Color.lerp(surfaceHighest, other.surfaceHighest, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
    );
  }
}
