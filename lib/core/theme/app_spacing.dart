import 'package:material_ui/material_ui.dart';

/// 4-point spacing grid (PLAN.md §6.3).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal screen margin.
  static const double screen = 16;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screen,
  );
}

/// Corner radii.
abstract final class AppRadius {
  static const double field = 10;
  static const double card = 16;
  static const double button = 14;
  static const double sheet = 24;
}

/// Touch target sizes.
abstract final class AppSizes {
  static const double minTouch = 48;

  /// Any action inside a session (validate, +/-, check).
  static const double sessionTouch = 56;

  static const double icon = 24;
  static const double iconDense = 20;
  static const double iconEmpty = 56;
}

/// Motion durations and curve (PLAN.md §6.5).
abstract final class AppMotion {
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration transition = Duration(milliseconds: 250);
  static const Curve curve = Curves.easeOutCubic;
}
