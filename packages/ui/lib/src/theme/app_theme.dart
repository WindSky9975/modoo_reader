import 'package:flutter/material.dart';

/// The four reading themes. Kept as an enum because the value is persisted.
enum AppThemeVariant { paper, sepia, night, amoled }

/// Colour tokens for one theme.
///
/// Reader surfaces use these directly; widgets must not hard-code hex colours
/// (CODE_STYLE §11.5).
final class AppPalette {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.foreground,
    required this.muted,
    required this.accent,
    required this.divider,
    required this.brightness,
  });

  final Color background;
  final Color surface;
  final Color foreground;
  final Color muted;
  final Color accent;
  final Color divider;
  final Brightness brightness;

  static const AppPalette paper = AppPalette(
    background: Color(0xFFFDFBF7),
    surface: Color(0xFFFFFFFF),
    foreground: Color(0xFF1F1B16),
    muted: Color(0xFF6B6259),
    accent: Color(0xFF8C5A2B),
    divider: Color(0xFFE6DFD4),
    brightness: Brightness.light,
  );

  static const AppPalette sepia = AppPalette(
    background: Color(0xFFF6ECD9),
    surface: Color(0xFFFBF3E4),
    foreground: Color(0xFF3B2F22),
    muted: Color(0xFF7A6A57),
    accent: Color(0xFF9C6B33),
    divider: Color(0xFFE2D3B8),
    brightness: Brightness.light,
  );

  static const AppPalette night = AppPalette(
    background: Color(0xFF121212),
    surface: Color(0xFF1C1C1E),
    foreground: Color(0xFFD9D4CC),
    muted: Color(0xFF8E8A84),
    accent: Color(0xFFC79A63),
    divider: Color(0xFF2C2C2E),
    brightness: Brightness.dark,
  );

  static const AppPalette amoled = AppPalette(
    background: Color(0xFF000000),
    surface: Color(0xFF0A0A0A),
    foreground: Color(0xFFCFCBC4),
    muted: Color(0xFF7C7873),
    accent: Color(0xFFB98B57),
    divider: Color(0xFF1F1F1F),
    brightness: Brightness.dark,
  );

  static AppPalette of(AppThemeVariant variant) => switch (variant) {
    AppThemeVariant.paper => paper,
    AppThemeVariant.sepia => sepia,
    AppThemeVariant.night => night,
    AppThemeVariant.amoled => amoled,
  };
}

/// Spacing scale, in logical pixels. Use these instead of magic numbers.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radii.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
}

/// Builds the [ThemeData] for [variant].
ThemeData buildAppTheme(AppThemeVariant variant) {
  final palette = AppPalette.of(variant);
  final scheme = ColorScheme.fromSeed(
    seedColor: palette.accent,
    brightness: palette.brightness,
    surface: palette.surface,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: palette.brightness,
    scaffoldBackgroundColor: palette.background,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: palette.foreground,
      displayColor: palette.foreground,
    ),
    dividerColor: palette.divider,
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.foreground,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  );
}
