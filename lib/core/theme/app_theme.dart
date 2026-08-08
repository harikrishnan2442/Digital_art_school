import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        palette: AppPalette.light,
        seedSurface: AppColors.cardWhite,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        palette: AppPalette.dark,
        seedSurface: AppPalette.dark.surface,
      );

  static ThemeData _build({
    required Brightness brightness,
    required AppPalette palette,
    required Color seedSurface,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        brightness: brightness,
        primary: AppColors.blue,
        secondary: AppColors.teal,
        surface: seedSurface,
      ),
      scaffoldBackgroundColor: palette.background,
      textTheme: (brightness == Brightness.dark
              ? GoogleFonts.poppinsTextTheme(ThemeData(brightness: Brightness.dark).textTheme)
              : GoogleFonts.poppinsTextTheme())
          .apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      extensions: [palette],
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface.withOpacity(0.92),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        titleTextStyle: GoogleFonts.poppins(
          color: palette.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : AppColors.coconut,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.blue.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.blue.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        labelStyle: GoogleFonts.poppins(color: palette.textSecondary, fontSize: 13),
        hintStyle: GoogleFonts.poppins(
            color: palette.textSecondary.withOpacity(0.65), fontSize: 13),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.blue,
        selectionColor: Color(0x330366B0),
        selectionHandleColor: AppColors.blue,
      ),
      cardColor: palette.surface,
      dividerColor: palette.divider,
    );
  }
}
