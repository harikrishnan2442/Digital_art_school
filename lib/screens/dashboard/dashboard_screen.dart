import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/liquid_glass_card.dart';
import '../../core/widgets/section_label.dart';
import '../../models/teacher.dart';
import '../../services/api_client.dart';
import '../../state/app_state.dart';
import '../shell/widgets/ai_chat_sheet.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final student = appState.student;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
      children: [
        _WelcomeCard(greeting: _greeting()),
        const SizedBox(height: 18),
        if (student != null && !student.hasTeacher) ...[
          SectionLabel('Find Your Teacher',
              trailing: Text('${appState.matchedTeachers.length} matched',
                  style: TextStyle(fontSize: 11.5, color: AppColors.slate.withOpacity(0.7)))),
          const _TeacherSelectionList(),
          const SizedBox(height: 18),
        ] else if (student != null) ...[
          const _EnrolledClassCard(),
          const SizedBox(height: 18),
        ],
        const SectionLabel('Practice Activity'),
        const _StreakHeatmapCard(),



        const SizedBox(height: 18),
        const SectionLabel('Calendar'),
        const _MiniCalendarCard(),
      ],
    );
  }
}

/// Welcome hero — a real frosted-glass surface (see `LiquidGlassCard`)
/// laid over a colourful gradient backdrop, so the "glass" genuinely
/// shows blurred colour through it rather than just being a
/// translucent card.
class _WelcomeCard extends StatefulWidget {
  final String greeting;
  const _WelcomeCard({required this.greeting});

  @override
  State<_WelcomeCard> createState() => _WelcomeCardState();
}

class _WelcomeCardState extends State<_WelcomeCard> {
  @override
  Widget build(BuildContext context) {
    final student = context.watch<AppState>().student;
    final hasTeacher = student?.hasTeacher ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          // Colourful backdrop the glass card blurs & tints. Positioned.fill
          // so it always matches whatever size the glass card ends up
          // being, instead of trying (and failing) to size itself.
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              child: Stack(
                children: [
                  Positioned(
                    top: -40,
                    right: -30,
                    child: _blob(AppColors.gold, 150),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -40,
                    child: _blob(AppColors.teal, 160),
                  ),
                ],
              ),
            ),
          ),
          LiquidGlassCard(
            borderRadius: 28,
            blurSigma: 34,
            tintOpacity: 0.4,
            tintGradient: AppColors.heroGradient,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        hasTeacher ? 'Enrolled' : 'New Student',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      _formattedDate(),
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11.5),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '${widget.greeting},',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Text(
                  student?.firstName ?? 'Artist',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  '"Every master was once a beginner. Your journey in the arts '
                      'starts here — one practice session at a time."',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      height: 1.5),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasTeacher ? '${student!.teacherName} — Class' : 'No class yet',
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              hasTeacher
                                  ? 'Check your schedule for timings'
                                  : 'Select a teacher to begin',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (hasTeacher)
                        TextButton.icon(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(AppIcons.forward, size: 15, color: AppColors.blue),
                          label: const Text('Enter Studio',
                              style: TextStyle(
                                  color: AppColors.blue, fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                if (student?.artCategory != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _pill(AppIcons.palette, student!.artCategory!),
                      if (student.artDiscipline != null)
                        _pill(AppIcons.brush, student.artDiscipline!),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withOpacity(0.55), color.withOpacity(0)]),
      ),
    );
  }

  String _formattedDate() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

class _EnrolledClassCard extends StatelessWidget {
  const _EnrolledClassCard();

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AppState>().student!;
    return GlassCard(
      glowColor: AppColors.teal,
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.teal.withOpacity(0.14),
            child: Text(
              student.teacherName!.substring(0, 1),
              style: const TextStyle(color: AppColors.teal, fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.teacherName!,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.deep)),
                const SizedBox(height: 3),
                Text('Your teacher · ${student.artDiscipline ?? student.artCategory ?? ''}',
                    style: TextStyle(fontSize: 12, color: AppColors.slate.withOpacity(0.85))),
              ],
            ),
          ),
          StatusPill(text: 'Active', color: AppColors.teal, icon: AppIcons.checkCircle),
        ],
      ),
    );
  }
}

class _TeacherSelectionList extends StatelessWidget {
  const _TeacherSelectionList();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    // Ranked by the rule-based matching engine — see
    // lib/services/teacher_matching_service.dart.
    final teachers = appState.matchedTeachers;

    return SizedBox(
      height: 236,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: teachers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _TeacherCard(teacher: teachers[i]),
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  final Teacher teacher;
  const _TeacherCard({required this.teacher});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pending = appState.hasPendingRequestFor(teacher);

    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blue.withOpacity(0.08)),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.blue.withOpacity(0.12),
                child: Text(teacher.initials,
                    style: const TextStyle(
                        color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(teacher.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    Text(teacher.specialization,
                        style: TextStyle(fontSize: 10.5, color: AppColors.slate.withOpacity(0.8))),
                  ],
                ),
              ),
              if (teacher.rating != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: AppColors.goldDeep),
                      const SizedBox(width: 2),
                      Text(teacher.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.goldDeep)),
                    ],
                  ),
                ),
            ],
          ),
          if (teacher.location != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 11, color: AppColors.slate.withOpacity(0.6)),
                const SizedBox(width: 3),
                Text(teacher.location!,
                    style: TextStyle(fontSize: 10, color: AppColors.slate.withOpacity(0.7))),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 3,
            runSpacing: 3,
            children: teacher.disciplines
                .map((d) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.coconut,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(d, style: const TextStyle(fontSize: 9.5, color: AppColors.slate)),
                    ))
                .toList(),
          ),
          const Spacer(),
          Text('${teacher.seatsLeft} seats left · ${teacher.experienceYears}y exp',
              style: TextStyle(fontSize: 10, color: AppColors.slate.withOpacity(0.65))),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            child: pending
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Request Sent',
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.goldDeep)),
                  )
                : GradientButton(
                    label: 'Request',
                    onPressed: () => _openRequestSheet(context, teacher),
                    expand: true,
                  ),
          ),
        ],
      ),
    );
  }

  void _openRequestSheet(BuildContext context, Teacher teacher) {
    final messageCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.slate.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Text('Request ${teacher.name}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.deep)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(teacher.specialization,
                      style: TextStyle(fontSize: 12.5, color: AppColors.slate.withOpacity(0.8))),
                  if (teacher.location != null) ...[
                    Text('  ·  ', style: TextStyle(color: AppColors.slate.withOpacity(0.5))),
                    Icon(Icons.location_on_outlined, size: 12, color: AppColors.slate.withOpacity(0.6)),
                    const SizedBox(width: 2),
                    Text(teacher.location!,
                        style: TextStyle(fontSize: 12, color: AppColors.slate.withOpacity(0.8))),
                  ],
                  if (teacher.rating != null) ...[
                    Text('  ·  ', style: TextStyle(color: AppColors.slate.withOpacity(0.5))),
                    const Icon(Icons.star_rounded, size: 13, color: AppColors.goldDeep),
                    Text(' ${teacher.rating!.toStringAsFixed(1)}',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.goldDeep)),
                  ],
                ],
              ),
              if (teacher.bio.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(teacher.bio,
                    style: TextStyle(fontSize: 12, color: AppColors.slate.withOpacity(0.85), height: 1.45)),
              ],
              if (teacher.languages.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: teacher.languages
                      .map((l) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.coconut,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(l,
                                style: const TextStyle(fontSize: 10.5, color: AppColors.slate)),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 18),
              const Text('Message to Teacher (optional)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.deep)),
              const SizedBox(height: 8),
              TextField(
                controller: messageCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Introduce yourself or share why you'd like to study with this teacher…",
                ),
              ),
              const SizedBox(height: 18),
              GradientButton(
                label: 'Send Request',
                icon: AppIcons.send,
                onPressed: () async {
                  final appState = context.read<AppState>();
                  final navigator = Navigator.of(ctx);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final request =
                        await appState.sendTeacherRequest(teacher, messageCtrl.text.trim());
                    navigator.pop();
                    messenger.showSnackBar(
                      SnackBar(content: Text('Request sent to ${teacher.name}')),
                    );
                    // Demo-only: without a live server, simulate the teacher
                    // responding after a short delay so the "enrolled"
                    // experience is reachable. With a live server, a real
                    // teacher needs to actually accept the request instead.
                    if (!appState.isUsingLiveApi) {
                      Future.delayed(const Duration(seconds: 5), () {
                        appState.simulateAcceptRequest(request);
                      });
                    }
                  } on ApiException catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text(e.message)));
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakHeatmapCard extends StatelessWidget {
  const _StreakHeatmapCard();

  @override
  Widget build(BuildContext context) {
    final rnd = Random(7);
    return GlassCard(
      glowColor: AppColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Last 35 days',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.deep)),
              StatusPill(text: '3-day streak', color: AppColors.gold, icon: AppIcons.flame),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(35, (i) {
              final intensity = rnd.nextDouble();
              final active = i >= 32; // last 3 days = current streak
              final color = active
                  ? AppColors.teal
                  : (intensity > 0.75
                      ? AppColors.blue
                      : (intensity > 0.45 ? AppColors.blue.withOpacity(0.4) : AppColors.coconut));
              return Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MiniCalendarCard extends StatefulWidget {
  const _MiniCalendarCard();

  @override
  State<_MiniCalendarCard> createState() => _MiniCalendarCardState();
}

class _MiniCalendarCardState extends State<_MiniCalendarCard> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  static const _weekdayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final firstOfMonth = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final startWeekday = firstOfMonth.weekday % 7; // make Sunday = 0

    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(AppIcons.chevronLeft, color: AppColors.slate),
                onPressed: () =>
                    setState(() => _month = DateTime(_month.year, _month.month - 1)),
              ),
              Text('${_monthNames[_month.month - 1]} ${_month.year}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.deep)),
              IconButton(
                icon: Icon(AppIcons.chevronRight, color: AppColors.slate),
                onPressed: () =>
                    setState(() => _month = DateTime(_month.year, _month.month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: _weekdayLabels
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate.withOpacity(0.55))),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemBuilder: (context, i) {
              if (i < startWeekday) return const SizedBox();
              final day = i - startWeekday + 1;
              final isToday = day == today.day &&
                  _month.month == today.month &&
                  _month.year == today.year;
              return Center(
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: isToday ? AppColors.mainGradient : null,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isToday ? Colors.white : AppColors.deep,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}




