import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

/// A small icon button that crossfades + rotates between a sun and a
/// moon as the app switches themes. The actual light↔dark colour
/// transition is handled by `MaterialApp.themeAnimationDuration` in
/// `app.dart` (built into Flutter) — this widget is just the crossfade
/// on the control itself.
class ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const ThemeToggleButton({super.key, required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) => RotationTransition(
            turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
            child: FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
          ),
          child: Icon(
            isDark ? AppIcons.moon : AppIcons.sun,
            key: ValueKey(isDark),
            color: isDark ? Colors.amberAccent : AppColors.goldDeep,
            size: 21,
          ),
        ),
      ),
    );
  }
}
