import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../state/app_state.dart';
import '../auth/login_screen.dart';
import '../shell/main_shell.dart';

/// Minimal, professional brand intro — just the logo, fading and
/// settling into place, the same restrained approach as the original
/// site's splash screen. While it plays, we quietly restore any
/// remembered session so returning users skip straight past login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final appState = context.read<AppState>();
    // Run the session restore and the minimum splash duration together,
    // so the screen never feels rushed and never overstays either.
    await Future.wait([
      appState.restoreSession(),
      Future.delayed(const Duration(milliseconds: 1600)),
    ]);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, __, ___) =>
            appState.isLoggedIn ? const MainShell() : const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coconut,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 108)
                .animate()
                .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.86, 0.86),
                  end: const Offset(1, 1),
                  duration: 700.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 22),
            const Text(
              'Digital Art School',
              style: TextStyle(
                color: AppColors.deep,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            )
                .animate(delay: 350.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.25, end: 0, duration: 500.ms, curve: Curves.easeOut),
            const SizedBox(height: 6),
            Text(
              'Preserving tradition through technology',
              style: TextStyle(
                color: AppColors.slate.withOpacity(0.75),
                fontSize: 12.5,
              ),
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }
}
