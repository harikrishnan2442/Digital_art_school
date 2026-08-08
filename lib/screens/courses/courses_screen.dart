import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/mock_data.dart';
import '../../models/course_module.dart';
import '../../state/app_state.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hasTeacher = context.watch<AppState>().student?.hasTeacher ?? false;

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.deep),
                    children: [
                      TextSpan(text: 'My '),
                      TextSpan(text: 'Courses', style: TextStyle(color: AppColors.blue)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start with the free orientation track while you wait for a '
                  'teacher to accept your request.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.slate.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.softShadow,
              ),
              child: TabBar(
                indicatorPadding: const EdgeInsets.symmetric(
                  horizontal: 0.01,
                  vertical: 3,
                ),
                indicator: BoxDecoration(
                  gradient: AppColors.mainGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.slate,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Orientation'),
                  Tab(text: 'Resources'),
                  Tab(text: 'Enrolled'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _OrientationTab(),
                const _ResourcesTab(),
                _EnrolledTab(hasTeacher: hasTeacher),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrientationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final modules = MockData.orientationModules;
    final doneCount = modules.where((m) => m.status == ModuleStatus.done).length;
    final pct = (doneCount / modules.length * 100).round();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.mainGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppColors.mdShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('FREE ACCESS — NO TEACHER REQUIRED',
                          style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 6),
                    const Text('Orientation & Foundation Track',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Foundation Curriculum',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.deep)),
                  Text('$doneCount of ${modules.length} complete',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.teal, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.coconut,
                  valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                ),
              ),
              const SizedBox(height: 6),
              Text('$pct% complete', style: TextStyle(fontSize: 11, color: AppColors.slate.withOpacity(0.7))),
              const SizedBox(height: 16),
              ...modules.map((m) => _ModuleTile(module: m)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final CourseModule module;
  const _ModuleTile({required this.module});

  @override
  Widget build(BuildContext context) {
    final done = module.status == ModuleStatus.done;
    final active = module.status == ModuleStatus.active;
    final locked = module.status == ModuleStatus.locked;

    Color numColor = locked ? AppColors.slate.withOpacity(0.35) : AppColors.blue;
    Color numBg = locked
        ? AppColors.coconut
        : (done ? AppColors.teal.withOpacity(0.12) : AppColors.blue.withOpacity(0.1));

    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? AppColors.blue.withOpacity(0.03) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.blue.withOpacity(0.06)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: numBg, borderRadius: BorderRadius.circular(10)),
              child: Text(module.number.toString().padLeft(2, '0'),
                  style: TextStyle(color: numColor, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.deep)),
                  const SizedBox(height: 3),
                  Text(module.description,
                      style: TextStyle(fontSize: 11.5, color: AppColors.slate.withOpacity(0.85), height: 1.4)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _typeColor(module.type).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(_typeLabel(module.type),
                            style: TextStyle(
                                fontSize: 9.5, fontWeight: FontWeight.w700, color: _typeColor(module.type))),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.schedule_rounded, size: 11, color: AppColors.slate.withOpacity(0.55)),
                      const SizedBox(width: 3),
                      Text('${module.durationMinutes} min',
                          style: TextStyle(fontSize: 10.5, color: AppColors.slate.withOpacity(0.65))),
                    ],
                  ),
                ],
              ),
            ),
            if (done)
              const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 20)
            else if (locked)
              Icon(Icons.lock_outline_rounded, color: AppColors.slate.withOpacity(0.4), size: 18)
            else
              const Icon(Icons.play_circle_fill_rounded, color: AppColors.blue, size: 22),
          ],
        ),
      ),
    );
  }

  Color _typeColor(ModuleType t) {
    switch (t) {
      case ModuleType.video:
        return AppColors.blue;
      case ModuleType.theory:
        return AppColors.goldDeep;
      case ModuleType.practice:
        return AppColors.teal;
    }
  }

  String _typeLabel(ModuleType t) {
    switch (t) {
      case ModuleType.video:
        return 'VIDEO';
      case ModuleType.theory:
        return 'THEORY';
      case ModuleType.practice:
        return 'PRACTICE';
    }
  }
}

class _ResourcesTab extends StatelessWidget {
  const _ResourcesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
      children: MockData.resources
          .map((r) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.description_outlined, color: AppColors.blue),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text(r.subtitle,
                              style: TextStyle(fontSize: 11.5, color: AppColors.slate.withOpacity(0.75))),
                        ],
                      ),
                    ),
                    const Icon(Icons.download_rounded, color: AppColors.slate),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _EnrolledTab extends StatelessWidget {
  final bool hasTeacher;
  const _EnrolledTab({required this.hasTeacher});

  @override
  Widget build(BuildContext context) {
    if (hasTeacher) {
      return const Center(child: Text('Your enrolled class content will appear here.'));
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded, color: AppColors.blue, size: 32),
            ),
            const SizedBox(height: 18),
            const Text('No Enrolled Courses Yet',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.deep)),
            const SizedBox(height: 8),
            Text(
              'Once a teacher accepts your request, your personal curriculum '
              'will unlock here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.slate.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
