import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Drop your logo file at `assets/images/logo.png` (already declared
/// in pubspec.yaml under `assets/images/`) and every brand mark in the
/// app — splash, login, header — will pick it up automatically.
///
/// Until then, this shows a simple monogram so nothing looks broken.
class AppLogo extends StatelessWidget {
  final double size;
  final bool onDark;

  const AppLogo({super.key, this.size = 44, this.onDark = false});

  static const String assetPath = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'DAS',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.28,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
