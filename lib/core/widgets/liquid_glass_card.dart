import 'package:cupertino_liquid_glass/cupertino_liquid_glass.dart';
import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

/// A real "Liquid Glass" surface (Apple's iOS 26 material, approximated
/// in pure Dart by the `cupertino_liquid_glass` package — no shader,
/// no native bridge, works everywhere): genuine background blur,
/// specular highlights, directional edge lighting, and a vibrancy
/// boost that lifts the saturation of whatever sits behind it.
///
/// On top of that, this widget adds its own translucent brand-colour
/// wash (`tintGradient`) and a soft diagonal sheen — the bit that
/// makes it read as *coloured* glass over your gradient/doodle
/// background, rather than a generic grey frost.
///
/// Needs something visually interesting behind it to look right (a
/// gradient, an image, real page content) — a flat single colour
/// won't show much through the blur, by design.
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;
  final double tintOpacity;

  /// The colour(s) of the glass itself — this is what makes it read
  /// as "blue glass" or "gold glass" rather than plain frosted white.
  /// Pass a brand gradient (e.g. `AppColors.heroGradient`) for a rich
  /// stained-glass look, or a single flat colour via
  /// `LinearGradient(colors: [c, c])` for a simpler tint.
  final Gradient tintGradient;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 28,
    this.blurSigma = 30,
    this.tintOpacity = 0.35,
    this.tintGradient = const LinearGradient(
      colors: [Colors.white, Colors.white],
    ),
  });

  @override
  Widget build(BuildContext context) {
    final edgeColor = context.palette.glassBorder;

    return CupertinoLiquidGlass(
      blurSigma: blurSigma,
      tintOpacity: tintOpacity,
      borderRadius: BorderRadius.circular(borderRadius),
      edgeLightColor: edgeColor.withOpacity(0.55),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // The stained-glass colour wash — sits above the package's
            // own neutral vibrancy/blur layer, so real brand hues show
            // clearly instead of a generic grey blur.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: _faded(tintGradient, 0.24)),
                ),
              ),
            ),
            // A soft diagonal sheen, like light catching the surface
            // of real glass — classic Liquid Glass/visionOS touch.
            Positioned(
              top: -50,
              left: -70,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: -0.38,
                  child: Container(
                    width: 280,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.30),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }

  /// Rebuilds [source] with every colour's opacity scaled down to
  /// [opacity], preserving its direction/stops. Works for any
  /// `Gradient` subtype `cupertino_liquid_glass`-style usage cares
  /// about (Linear is by far the common case here).
  Gradient _faded(Gradient source, double opacity) {
    final fadedColors = source.colors.map((c) => c.withOpacity(opacity)).toList();
    if (source is LinearGradient) {
      return LinearGradient(
        begin: source.begin,
        end: source.end,
        stops: source.stops,
        colors: fadedColors,
      );
    }
    if (source is RadialGradient) {
      return RadialGradient(
        center: source.center,
        radius: source.radius,
        stops: source.stops,
        colors: fadedColors,
      );
    }
    return LinearGradient(colors: fadedColors);
  }
}
