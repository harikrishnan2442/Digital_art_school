import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../state/app_state.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AppState>().student;
    final hasTeacher = student?.hasTeacher ?? false;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text('My Schedule',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.deep)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                children: [
                  _viewChip('Week', true),
                  _viewChip('Month', false),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          hasTeacher
              ? 'Your confirmed sessions with ${student!.teacherName}.'
              : 'Your calendar opens up once a teacher accepts your request.',
          style: TextStyle(fontSize: 12.5, color: AppColors.slate.withOpacity(0.85)),
        ),
        const SizedBox(height: 18),
        if (!hasTeacher) _UpcomingBanner(),
        if (!hasTeacher) const SizedBox(height: 18),
        _WeekGrid(hasTeacher: hasTeacher, teacherName: student?.teacherName),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                color: AppColors.blue,
                icon: Icons.school_rounded,
                title: 'Free Orientation',
                body: 'Self-paced modules available right now, no teacher needed.',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoCard(
                color: AppColors.teal,
                icon: Icons.groups_rounded,
                title: 'Find a Teacher',
                body: 'Browse and request a teacher from your dashboard.',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          color: AppColors.gold,
          icon: Icons.notifications_active_rounded,
          title: 'Stay in the loop',
          body: 'We\'ll notify you the moment a teacher responds to your request.',
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _viewChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: active ? AppColors.mainGradient : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.slate)),
    );
  }
}

class _UpcomingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.emoji_objects_rounded, color: AppColors.goldDeep),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome & Orientation Session',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.deep)),
                SizedBox(height: 2),
                Text('Self-paced — start whenever you\'re ready',
                    style: TextStyle(fontSize: 11, color: AppColors.slate)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekGrid extends StatelessWidget {
  final bool hasTeacher;
  final String? teacherName;
  const _WeekGrid({required this.hasTeacher, this.teacherName});

  static const _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: List.generate(7, (i) {
              final day = startOfWeek.add(Duration(days: i));
              final isToday = day.day == now.day && day.month == now.month;
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.03),
                    border: Border(
                      bottom: BorderSide(color: AppColors.blue.withOpacity(0.08)),
                      right: i != 6
                          ? BorderSide(color: AppColors.blue.withOpacity(0.06))
                          : BorderSide.none,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(_days[i],
                          style: TextStyle(
                              fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.slate.withOpacity(0.7))),
                      const SizedBox(height: 4),
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: isToday ? AppColors.mainGradient : null,
                          shape: BoxShape.circle,
                        ),
                        child: Text('${day.day}',
                            style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isToday ? Colors.white : AppColors.deep)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            child: hasTeacher
                ? Column(
                    children: [
                      const Icon(Icons.event_available_rounded, color: AppColors.teal, size: 40),
                      const SizedBox(height: 14),
                      Text('Sessions with $teacherName appear here once scheduled.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: AppColors.slate.withOpacity(0.85))),
                    ],
                  )
                : Column(
                    children: [
                      Icon(Icons.calendar_month_rounded, color: AppColors.blue.withOpacity(0.25), size: 48),
                      const SizedBox(height: 16),
                      const Text('No Classes Scheduled Yet',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.deep)),
                      const SizedBox(height: 8),
                      Text(
                        'Request a teacher from your dashboard to unlock your '
                        'personal weekly schedule.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.slate.withOpacity(0.8), height: 1.5),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String body;
  final bool fullWidth;

  const _InfoCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.deep)),
          const SizedBox(height: 4),
          Text(body, style: TextStyle(fontSize: 11, color: AppColors.slate.withOpacity(0.8), height: 1.4)),
        ],
      ),
    );
  }
}
