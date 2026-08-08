import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/splash/splash_screen.dart';

class DigitalArtSchoolApp extends StatelessWidget {
  const DigitalArtSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) => MaterialApp(
          title: 'Digital Art School',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: appState.themeMode,
          // Built-in Flutter crossfade between light/dark ThemeData —
          // this is what makes the toggle in the header feel smooth
          // instead of an instant colour snap.
          themeAnimationDuration: const Duration(milliseconds: 450),
          themeAnimationCurve: Curves.easeInOut,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
