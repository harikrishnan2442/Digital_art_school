import 'package:flutter/material.dart';

/// A soft, blurred colour orb — the Flutter equivalent of the
/// `.widget-glow` decorative pseudo-elements in the original CSS.
/// Drop it inside a `Stack` behind your card content.
class GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const GlowOrb({
    super.key,
    required this.color,
    this.size = 160,
    this.opacity = 0.22,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }
}
