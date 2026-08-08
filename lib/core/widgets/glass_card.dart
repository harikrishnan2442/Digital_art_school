import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glow_orb.dart';

/// The Flutter equivalent of the recurring `.widget` card from the
/// original CSS: white rounded surface, soft blue shadow, thin
/// hairline border, and an optional glow orb tucked in a corner.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;
  final double borderRadius;
  final Alignment glowAlignment;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.glowColor,
    this.borderRadius = 24,
    this.glowAlignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.blue.withOpacity(0.08)),
        boxShadow: AppColors.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (glowColor != null)
            Align(
              alignment: glowAlignment,
              child: FractionalTranslation(
                translation: glowAlignment == Alignment.topRight
                    ? const Offset(0.3, -0.3)
                    : const Offset(-0.3, -0.3),
                child: GlowOrb(color: glowColor!),
              ),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
