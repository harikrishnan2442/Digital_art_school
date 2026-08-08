import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  final VoidCallback onLogout;

  const SettingsScreen({super.key, required this.onNavigate, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final hasTeacher = appState.student?.hasTeacher ?? false;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
      children: [
        const Text('Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.deep)),
        const SizedBox(height: 4),
        Text('Manage your account, preferences, and privacy.',
            style: TextStyle(fontSize: 12.5, color: AppColors.slate.withOpacity(0.85))),
        const SizedBox(height: 20),

        _SettingsCard(
          icon: Icons.palette_outlined,
          iconGradient: AppColors.mainGradient,
          title: 'Theme & Display',
          subtitle: 'Choose how Digital Art School looks on your device',
          children: [
            _SwitchRow(
              label: 'Match device theme',
              value: appState.darkModeFollowSystem,
              onChanged: appState.setDarkModeFollowSystem,
            ),
          ],
        ),
        const SizedBox(height: 14),

        _SettingsCard(
          icon: Icons.badge_outlined,
          iconGradient: AppColors.mainGradient,
          title: 'Personal Information',
          subtitle: 'Update your name, email, and profile details',
          children: [
            OutlinedButton.icon(
              onPressed: () => onNavigate(4),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit in My Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blue,
                side: BorderSide(color: AppColors.blue.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _SettingsCard(
          icon: Icons.notifications_none_rounded,
          iconGradient: AppColors.tealGradient,
          title: 'Notification Preferences',
          subtitle: 'Control what alerts you receive and how',
          children: [
            _SwitchRow(
              label: 'Email notifications',
              value: appState.emailNotifications,
              onChanged: appState.setEmailNotifications,
            ),
            _SwitchRow(
              label: 'Session reminders',
              value: appState.sessionReminders,
              onChanged: appState.setSessionReminders,
            ),
            _SwitchRow(
              label: 'Community digest',
              value: appState.communityDigest,
              onChanged: appState.setCommunityDigest,
            ),
          ],
        ),
        const SizedBox(height: 14),

        _SettingsCard(
          icon: Icons.shield_outlined,
          iconGradient: AppColors.goldGradient,
          title: 'Privacy Settings',
          subtitle: 'Manage what information is visible and shared',
          children: [
            _SwitchRow(
              label: 'Profile visible to teachers',
              value: appState.profileVisibleToTeachers,
              onChanged: appState.setProfileVisibleToTeachers,
            ),
            _SwitchRow(
              label: 'Show progress publicly',
              value: appState.showProgressPublicly,
              onChanged: appState.setShowProgressPublicly,
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (hasTeacher) ...[
          _SettingsCard(
            icon: Icons.groups_rounded,
            iconGradient: AppColors.mainGradient,
            title: 'My Enrolled Class',
            subtitle: 'Manage your class, teacher connection, and communication',
            children: [
              Text('Teacher: ${appState.student!.teacherName}',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.deep)),
            ],
          ),
          const SizedBox(height: 14),
          _SettingsCard(
            icon: Icons.tune_rounded,
            iconGradient: AppColors.tealGradient,
            title: 'Class Preferences',
            subtitle: 'Control how your class sessions work',
            children: const [
              _StaticRow('Session reminders', '30 minutes before'),
              _StaticRow('Recording access', 'Enabled'),
            ],
          ),
          const SizedBox(height: 14),
          _SettingsCard(
            icon: Icons.videocam_outlined,
            iconGradient: AppColors.deepGradient,
            title: 'Virtual Studio Settings',
            subtitle: 'Configure your audio, video, and session environment',
            children: const [
              _StaticRow('Camera', 'Ask before joining'),
              _StaticRow('Microphone', 'Ask before joining'),
            ],
          ),
          const SizedBox(height: 14),
          _SettingsCard(
            icon: Icons.assignment_outlined,
            iconGradient: AppColors.goldGradient,
            title: 'Assignment Preferences',
            subtitle: 'Configure how you submit and receive work',
            children: const [
              _StaticRow('Submission format', 'Video or written'),
              _StaticRow('Feedback delivery', 'In-app + email'),
            ],
          ),
        ] else ...[
          _LockedCard(
            icon: Icons.groups_rounded,
            title: 'Class Settings',
            subtitle: 'Enrol in a class to unlock these settings',
            onNavigate: () => onNavigate(0),
          ),
          const SizedBox(height: 14),
          _LockedCard(
            icon: Icons.calendar_today_rounded,
            title: 'Schedule & Sessions',
            subtitle: 'Your class timetable will appear here once enrolled',
            onNavigate: () => onNavigate(0),
          ),
        ],
        const SizedBox(height: 14),

        _SettingsCard(
          icon: Icons.security_rounded,
          iconGradient: AppColors.deepGradient,
          title: 'Security',
          subtitle: 'Protect your account with a strong password',
          children: [
            OutlinedButton.icon(
              onPressed: () => onNavigate(4),
              icon: const Icon(Icons.lock_outline_rounded, size: 16),
              label: const Text('Change Password'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blue,
                side: BorderSide(color: AppColors.blue.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _SettingsCard(
          icon: Icons.language_rounded,
          iconGradient: AppColors.tealGradient,
          title: 'Language & Region',
          subtitle: 'Set your preferred language and time zone',
          children: const [
            _StaticRow('Language', 'English'),
            _StaticRow('Time zone', 'Asia/Kolkata (IST)'),
          ],
        ),
        const SizedBox(height: 14),

        _SettingsCard(
          icon: Icons.storage_rounded,
          iconGradient: AppColors.mainGradient,
          title: 'Data & Storage',
          subtitle: 'Manage your data, exports, and account deletion',
          children: [
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Preparing your data export…'))),
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Export My Data'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blue,
                side: BorderSide(color: AppColors.blue.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _DangerZoneCard(onLogout: onLogout),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final Gradient iconGradient;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SettingsCard({
    required this.icon,
    required this.iconGradient,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(gradient: iconGradient, borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.deep)),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.slate.withOpacity(0.7))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.deep)),
          ),
          Switch(
            value: value,
            activeColor: AppColors.blue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _StaticRow extends StatelessWidget {
  final String label;
  final String value;
  const _StaticRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.slate.withOpacity(0.8))),
          ),
          Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.deep)),
        ],
      ),
    );
  }
}

class _LockedCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onNavigate;

  const _LockedCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.75,
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppColors.coconut, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: AppColors.slate.withOpacity(0.5), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.deep)),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.slate.withOpacity(0.7))),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.blue),
              onPressed: onNavigate,
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  final VoidCallback onLogout;
  const _DangerZoneCard({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.danger.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Danger Zone',
              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 3),
          Text('These actions cannot be undone',
              style: TextStyle(fontSize: 11, color: AppColors.slate.withOpacity(0.8))),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.danger),
              label: const Text('Log Out', style: TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
              label: const Text('Delete Account', style: TextStyle(color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete your account?'),
        content: const Text(
            'This permanently removes your profile, progress, and requests. '
            'This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onLogout();
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
