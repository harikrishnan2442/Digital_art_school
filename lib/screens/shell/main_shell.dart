import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/background_doodle.dart';
import '../../core/widgets/theme_toggle_button.dart';
import '../../state/app_state.dart';
import '../auth/login_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../schedule/schedule_screen.dart';
import '../courses/courses_screen.dart';
import '../progress/progress_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/floating_ai_bar.dart';

class NavDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavDestination(this.icon, this.activeIcon, this.label);
}

// Profile intentionally isn't a bottom-nav destination anymore — it
// lives in the header instead (tap the avatar next to the bell). The
// list below only covers what's still in the bottom bar.
const _destinations = [
  NavDestination(AppIcons.dashboard, AppIcons.dashboard, 'Dashboard'),
  NavDestination(AppIcons.schedule, AppIcons.schedule, 'Schedule'),
  NavDestination(AppIcons.courses, AppIcons.courses, 'Courses'),
  NavDestination(AppIcons.progress, AppIcons.progress, 'Progress'),
  NavDestination(AppIcons.settings, AppIcons.settings, 'Settings'),
];

// Screen index -> header title. Kept separate from `_destinations`
// since Profile (index 4) has a title but no bottom-nav slot.
const _screenLabels = ['Dashboard', 'Schedule', 'Courses', 'Progress', 'My Profile', 'Settings'];

// Maps each bottom-nav visual slot to its actual screen index in
// `_screens` below (Profile sits at screen index 4 but isn't one of
// these slots, so Settings shifts from slot 5 to slot 4).
const _bottomNavScreenIndices = [0, 1, 2, 3, 5];

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  List<Widget> get _screens => [
        DashboardScreen(onNavigate: (i) => setState(() => _index = i)),
        const ScheduleScreen(),
        const CoursesScreen(),
        const ProgressScreen(),
        const ProfileScreen(),
        SettingsScreen(
          onNavigate: (i) => setState(() => _index = i),
          onLogout: _handleLogout,
        ),
      ];

  Future<void> _handleLogout() async {
    await context.read<AppState>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      extendBody: true,
      floatingActionButton: const FloatingAiBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          const BackgroundDoodle(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _GlassHeader(
                  currentLabel: _screenLabels[_index],
                  onOpenProfile: () => setState(() => _index = 4),
                ),
                Expanded(
                  child: IndexedStack(index: _index, children: _screens),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _FloatingNavBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _GlassHeader extends StatelessWidget {
  final String currentLabel;
  final VoidCallback onOpenProfile;

  const _GlassHeader({required this.currentLabel, required this.onOpenProfile});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final student = appState.student;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 70, // slightly larger than the 75px logo
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.001),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppLogo(size: 60), // increase if needed
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              currentLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          ThemeToggleButton(
            isDark: appState.isDarkMode,
            onToggle: () => appState.toggleTheme(),
          ),
          IconButton(
            onPressed: () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(AppIcons.bell, color: Theme.of(context).textTheme.bodyLarge?.color),
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.dangerBright, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
          // Profile now lives here — right after the notification bell —
          // instead of in the bottom nav bar.
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onOpenProfile,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.blue.withOpacity(0.12),
                child: Text(
                  student?.initials ?? 'ST',
                  style: const TextStyle(
                      color: AppColors.blue, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _FloatingNavBar({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.deep,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.deep.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_destinations.length, (i) {
            final screenIndex = _bottomNavScreenIndices[i];
            final selected = screenIndex == index;
            final dest = _destinations[i];
            return GestureDetector(
              onTap: () => onChanged(screenIndex),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withOpacity(0.14) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  selected ? dest.activeIcon : dest.icon,
                  color: selected ? AppColors.gold : Colors.white.withOpacity(0.55),
                  size: 22,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
