import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic colour tokens that differ between light and dark mode.
///
/// Brand colours (blue/teal/gold/gradients) stay the same in both
/// modes — see `AppColors` — but "what's the page background", "what
/// colour is a card", and "what colour is body text" all need to
/// flip. Screens read these via `context.palette` instead of
/// hardcoding `Colors.white` / `AppColors.deep`.
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color glassTint;
  final Color glassBorder;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.glassTint,
    required this.glassBorder,
  });

  static const light = AppPalette(
    background: AppColors.pageBg,
    surface: AppColors.cardWhite,
    textPrimary: AppColors.deep,
    textSecondary: AppColors.slate,
    divider: Color(0x140366B0),
    glassTint: Colors.white,
    glassBorder: Colors.white,
  );

  static const dark = AppPalette(
    background: Color(0xFF0A1420),
    surface: Color(0xFF11203A),
    textPrimary: Color(0xFFF2F6FB),
    textSecondary: Color(0xFFA9B8CC),
    divider: Color(0x1AFFFFFF),
    glassTint: Color(0xFF1B2C4A),
    glassBorder: Colors.white,
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? glassTint,
    Color? glassBorder,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      glassTint: glassTint ?? this.glassTint,
      glassBorder: glassBorder ?? this.glassBorder,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      glassTint: Color.lerp(glassTint, other.glassTint, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// Shorthand: `context.palette.textPrimary` etc.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
