import 'package:flutter/material.dart';

/// Drop a doodle/pattern image at `assets/images/background_doodle.png`
/// (already declared in pubspec.yaml) and it'll show behind the app's
/// main screens, exactly like the doodle background on the original
/// site — including blurred through `LiquidGlassCard` surfaces like
/// the dashboard's welcome hero, which is why this sits a bit more
/// visible than a typical "barely-there" background pattern: glass
/// needs something with real contrast behind it to read as glass.
/// Until that file exists, this paints nothing — `errorBuilder`
/// swallows the "asset not found" error so the app never crashes
/// waiting for art.
class BackgroundDoodle extends StatelessWidget {
  final double opacity;

  const BackgroundDoodle({super.key, this.opacity = 0.16});

  static const String assetPath = 'assets/images/background_doodle.png';

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
