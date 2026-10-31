import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

/// Inter, embedded in `assets/fonts/` (PLAN.md §6.2). Weights 400 and 600 only.
abstract final class AppTypography {
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight semiBold = FontWeight.w600;

  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    final base = GoogleFonts.interTextTheme();
    TextStyle? style(
      TextStyle? s,
      double size,
      FontWeight weight, {
      Color? color,
      double? height,
    }) => s?.copyWith(
      fontSize: size,
      fontWeight: weight,
      color: color ?? onSurface,
      height: height,
      letterSpacing: 0,
    );

    return base.copyWith(
      displayLarge: style(base.displayLarge, 48, semiBold, height: 1.1),
      displayMedium: style(base.displayMedium, 40, semiBold, height: 1.1),
      displaySmall: style(base.displaySmall, 32, semiBold, height: 1.15),
      headlineLarge: style(base.headlineLarge, 28, semiBold),
      headlineMedium: style(base.headlineMedium, 26, semiBold),
      headlineSmall: style(base.headlineSmall, 24, semiBold, height: 1.2),
      titleLarge: style(base.titleLarge, 20, semiBold),
      titleMedium: style(base.titleMedium, 16, semiBold),
      titleSmall: style(base.titleSmall, 14, semiBold),
      bodyLarge: style(base.bodyLarge, 16, regular),
      bodyMedium: style(base.bodyMedium, 14, regular),
      bodySmall: style(base.bodySmall, 12, regular, color: onSurfaceVariant),
      labelLarge: style(base.labelLarge, 14, semiBold),
      labelMedium: style(base.labelMedium, 12, semiBold),
      labelSmall: style(base.labelSmall, 11, semiBold, color: onSurfaceVariant),
    );
  }
}

extension TabularFigures on TextStyle? {
  /// Same style with tabular figures, for numbers that change.
  TextStyle? get tabular =>
      this?.copyWith(fontFeatures: AppTypography.tabularFigures);
}
