import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/section_label.dart';
import '../../data/mock_data.dart';
import '../../models/schedule_event.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
      children: [
        const Text('My Progress',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.deep)),
        const SizedBox(height: 4),
        Text('See how far you\'ve come — and what unlocks next.',
            style: TextStyle(fontSize: 12.5, color: AppColors.slate.withOpacity(0.85))),
        const SizedBox(height: 20),
        const _ScoreCard(),
        const SizedBox(height: 18),
        const SectionLabel('Your Learning Journey'),
        GlassCard(child: _JourneyTimeline()),
        const SizedBox(height: 18),
        const SectionLabel('Badges'),
        const _BadgesGrid(),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard();

  @override
  Widget build(BuildContext context) {
    const pct = 0.12;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.deepGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.mdShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile Completion Score',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: CircularProgressIndicator(
                        value: pct,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withOpacity(0.14),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${(pct * 100).round()}%',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                        const Text('done', style: TextStyle(color: Colors.white60, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Getting Started',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 5),
                    Text(
                      'Complete all onboarding steps to reach 100% and unlock '
                      'your full curriculum.',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11.5, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _breakdownRow('Account & Profile', 1.0),
          _breakdownRow('Teacher Assigned', 0.0),
          _breakdownRow('First Class Attended', 0.0),
          _breakdownRow('Orientation Modules', 0.6),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.12),
                valueColor: const AlwaysStoppedAnimation(AppColors.gold),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('${(value * 100).round()}%',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _JourneyTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = MockData.journeySteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final isLast = i == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _dot(step.status),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: step.status == JourneyStepStatus.done
                            ? AppColors.teal.withOpacity(0.4)
                            : AppColors.blue.withOpacity(0.12),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Opacity(
                    opacity: step.status == JourneyStepStatus.locked ? 0.5 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(step.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.deep)),
                            ),
                            _statusBadge(step.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(step.description,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.slate.withOpacity(0.85), height: 1.5)),
                        if (step.detail != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.coconut,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(step.detail!,
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.slate.withOpacity(0.85), height: 1.4)),
                          ),
                        ],
                        if (step.actionLabel != null) ...[
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 14),
                            label: Text(step.actionLabel!,
                                style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _dot(JourneyStepStatus status) {
    switch (status) {
      case JourneyStepStatus.done:
        return Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 13),
        );
      case JourneyStepStatus.active:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blue, width: 3),
          ),
        );
      case JourneyStepStatus.pending:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.coconut,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.blue.withOpacity(0.25), width: 2),
          ),
        );
      case JourneyStepStatus.locked:
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: AppColors.coconut, shape: BoxShape.circle),
          child: Icon(Icons.lock_outline_rounded, size: 11, color: AppColors.slate.withOpacity(0.4)),
        );
    }
  }

  Widget _statusBadge(JourneyStepStatus status) {
    switch (status) {
      case JourneyStepStatus.done:
        return const StatusPill(text: 'Complete', color: AppColors.teal, icon: Icons.check_rounded);
      case JourneyStepStatus.active:
        return const StatusPill(text: 'In Progress', color: AppColors.blue);
      case JourneyStepStatus.pending:
        return const StatusPill(text: 'Waiting', color: AppColors.gold);
      case JourneyStepStatus.locked:
        return StatusPill(text: 'Locked', color: AppColors.slate.withOpacity(0.6));
    }
  }
}

class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: MockData.badges.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, i) {
          final badge = MockData.badges[i];
          return Opacity(
            opacity: badge.earned ? 1 : 0.4,
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: (badge.earned ? AppColors.teal : AppColors.slate).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badge.earned ? Icons.military_tech_rounded : Icons.lock_outline_rounded,
                    color: badge.earned ? AppColors.teal : AppColors.slate,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.deep),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
