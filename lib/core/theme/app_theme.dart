import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:endelea/core/theme/app_colors.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/theme/app_typography.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the "Savane" themes (PLAN.md §6).
abstract final class AppTheme {
  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    colors: AppColors.dark,
    primary: SavanePalette.darkPrimary,
    onPrimary: SavanePalette.darkOnPrimary,
    secondary: SavanePalette.darkSecondary,
    error: SavanePalette.darkError,
    outline: SavanePalette.darkOutline,
    onSurface: SavanePalette.darkOnSurface,
    onSurfaceVariant: SavanePalette.darkOnSurfaceVariant,
  );

  static ThemeData get light => _build(
    brightness: Brightness.light,
    colors: AppColors.light,
    primary: SavanePalette.lightPrimary,
    onPrimary: SavanePalette.lightOnPrimary,
    secondary: SavanePalette.lightSecondary,
    error: SavanePalette.lightError,
    outline: SavanePalette.lightOutline,
    onSurface: SavanePalette.lightOnSurface,
    onSurfaceVariant: SavanePalette.lightOnSurfaceVariant,
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppColors colors,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color error,
    required Color outline,
    required Color onSurface,
    required Color onSurfaceVariant,
  }) {
    final onDark = brightness == Brightness.dark
        ? SavanePalette.darkBackground
        : SavanePalette.lightSurface;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: SavanePalette.seed,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          primaryContainer: colors.surfaceHighest,
          onPrimaryContainer: onSurface,
          secondary: secondary,
          onSecondary: onDark,
          secondaryContainer: colors.surfaceHighest,
          onSecondaryContainer: onSurface,
          tertiary: colors.success,
          onTertiary: colors.onSuccess,
          error: error,
          onError: onDark,
          surface: colors.background,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          surfaceContainerLowest: colors.background,
          surfaceContainerLow: colors.surface,
          surfaceContainer: colors.surface,
          surfaceContainerHigh: colors.surfaceHigh,
          surfaceContainerHighest: colors.surfaceHighest,
          outline: outline,
          outlineVariant: outline,
        );
    final text = AppTypography.textTheme(onSurface, onSurfaceVariant);

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.surfaceHighest,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? onSurface
                : onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: AppSizes.icon,
            color: states.contains(WidgetState.selected)
                ? primary
                : onSurfaceVariant,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(AppSizes.sessionTouch),
          textStyle: text.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          minimumSize: const Size(AppSizes.minTouch, AppSizes.minTouch),
          side: BorderSide(color: outline),
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(AppSizes.minTouch, AppSizes.minTouch),
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppSizes.minTouch, AppSizes.minTouch),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.surfaceHighest,
        foregroundColor: onSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceHigh,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: fieldBorder.copyWith(borderSide: BorderSide(color: error)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceHigh,
        selectedColor: colors.surfaceHighest,
        side: BorderSide(color: outline),
        labelStyle: text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, space: 1, thickness: 1),
      listTileTheme: ListTileThemeData(
        iconColor: onSurfaceVariant,
        minTileHeight: AppSizes.minTouch + AppSpacing.sm,
        contentPadding: AppSpacing.screenPadding,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surfaceHighest,
        contentTextStyle: text.bodyMedium,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: colors.surfaceHighest,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? onPrimary : outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : colors.surfaceHighest,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
