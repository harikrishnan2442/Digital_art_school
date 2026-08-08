import 'package:flutter/material.dart';

/// Colour system lifted 1:1 from the original project's `:root` CSS
/// variables, so the Flutter app stays visually consistent with the
/// PHP version it was rebuilt from.
class AppColors {
  AppColors._();

  static const Color blue = Color(0xFF0366B0);
  static const Color blueDeep = Color(0xFF0050A0);
  static const Color teal = Color(0xFF02B393);
  static const Color lime = Color(0xFFA3CE47);
  static const Color gold = Color(0xFFF3C73B);
  static const Color goldDeep = Color(0xFFC49A00);
  static const Color slate = Color(0xFF606060);
  static const Color deep = Color(0xFF0D1F35);
  static const Color deepDark = Color(0xFF0A1628);
  static const Color coconut = Color(0xFFF4FAFF);
  static const Color danger = Color(0xFFC74A3C);
  static const Color dangerBright = Color(0xFFE74C3C);

  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color pageBg = Color(0xFFF4FAFF);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, slate],
  );

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, slate],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [teal, Color(0xFF00997A)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, goldDeep],
  );

  static const LinearGradient deepGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deep, deepDark],
  );

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: blue.withOpacity(0.10),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> mdShadow = [
    BoxShadow(
      color: blue.withOpacity(0.14),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];
}
