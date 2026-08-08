import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../models/student.dart';
import '../../services/api_client.dart';
import '../../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final student = appState.student;
    if (student == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: () async {
        try {
          await context.read<AppState>().refreshProfileFromServer();
        } on ApiException catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
          }
        }
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
        children: [
          _ProfileHeader(student: student),
          const SizedBox(height: 14),
          _ConnectionBadge(isLive: appState.isUsingLiveApi),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.badge_outlined,
            iconColor: AppColors.blue,
            title: 'Account Details',
            subtitle: 'Basic personal information',
            rows: [
              _Row('Full Name', student.fullName),
              _Row('Email', student.email),
              _Row('Age', student.age?.toString() ?? '—'),
              _Row('Location', student.location ?? '—'),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.palette_outlined,
            iconColor: AppColors.teal,
            title: 'Art & Interests',
            subtitle: 'Your chosen art form and disciplines',
            rows: [
              _Row('Art Category', student.artCategory ?? '—'),
              _Row('Art Discipline', student.artDiscipline ?? '—'),
              _Row('Secondary Interests', student.secondaryInterest ?? '—'),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.gold,
            title: 'Experience & Background',
            subtitle: 'Your training history and skill level',
            rows: [
              _Row('Skill Level', student.skillLevel?.label ?? '—'),
              _Row('Years of Experience', student.yearsOfExperience?.toString() ?? '—'),
              _Row('Previous Training', student.previousTraining ?? '—'),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.flag_outlined,
            iconColor: AppColors.blueDeep,
            title: 'Learning Goals & Schedule',
            subtitle: 'Your purpose, availability, and aspirations',
            rows: [
              _Row('Learning Purpose', student.learningPurpose?.label ?? '—'),
              _Row('Time Commitment', student.timeCommitment ?? '—'),
              _Row('Preferred Schedule', student.preferredSchedule ?? '—'),
              _Row('Specific Goals', student.specificGoals ?? '—'),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.accessibility_new_rounded,
            iconColor: AppColors.danger,
            title: 'Health & Accessibility',
            subtitle: 'Optional — helps your teacher tailor sessions for you',
            rows: [
              _Row('Physical Constraints', student.physicalConstraints ?? 'None specified'),
              _Row('Learning Accommodations', student.learningAccommodations ?? 'None specified'),
            ],
          ),
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.history_rounded,
            iconColor: AppColors.slate,
            title: 'Account History',
            subtitle: 'From your student record',
            rows: [
              _Row('Member Since', _formatDate(student.registrationDate)),
              _Row('Last Login', student.lastLogin != null ? _formatDate(student.lastLogin) : 'This is your first login'),
            ],
          ),
          const SizedBox(height: 14),
          const _ChangePasswordCard(),
        ],
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  final bool isLive;
  const _ConnectionBadge({required this.isLive});

  @override
  Widget build(BuildContext context) {
    final color = isLive ? AppColors.teal : AppColors.gold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(isLive ? Icons.cloud_done_rounded : Icons.cloud_off_rounded, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isLive
                  ? 'This data is live from your MySQL database. Pull to refresh.'
                  : 'Demo mode — set API_BASE_URL in .env to load your real database.',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final Student student;
  const _ProfileHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.mdShadow,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(student.initials,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22)),
          ),
          const SizedBox(height: 12),
          Text(student.fullName,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
          const SizedBox(height: 3),
          Text(student.artDiscipline ?? student.artCategory ?? 'Art Student',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.5)),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _stat(student.skillLevel?.label ?? '—', 'Skill Level'),
              Container(width: 1, height: 32, color: Colors.white24),
              _stat(
                  student.yearsOfExperience != null ? '${student.yearsOfExperience}y' : '—',
                  'Experience'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10.5)),
      ],
    );
  }
}

class _Row {
  final String label;
  final String value;
  _Row(this.label, this.value);
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<_Row> rows;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.rows,
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
                decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, color: iconColor, size: 18),
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
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(r.label, style: TextStyle(fontSize: 11.5, color: AppColors.slate.withOpacity(0.75))),
                    ),
                    Expanded(
                      child: Text(r.value,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.deep)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ChangePasswordCard extends StatefulWidget {
  const _ChangePasswordCard();

  @override
  State<_ChangePasswordCard> createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<_ChangePasswordCard> {
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_newPassCtrl.text.isEmpty) return;
    if (_newPassCtrl.text.length < 8) {
      setState(() => _error = 'Minimum 8 characters');
      return;
    }
    if (_newPassCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    try {
      await context.read<AppState>().changePassword(_newPassCtrl.text);
      _newPassCtrl.clear();
      _confirmCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated')),
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
                decoration: BoxDecoration(
                    gradient: AppColors.deepGradient, borderRadius: BorderRadius.circular(11)),
                child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Change Password',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.deep)),
                    Text('Leave blank to keep your current password',
                        style: TextStyle(fontSize: 11, color: AppColors.slate)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm New Password'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 11.5)),
          ],
          const SizedBox(height: 14),
          GradientButton(
            label: 'Update Password',
            loading: _saving,
            onPressed: _saving ? null : _save,
            expand: true,
          ),
        ],
      ),
    );
  }
}
