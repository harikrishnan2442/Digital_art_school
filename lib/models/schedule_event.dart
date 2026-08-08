class ScheduleEvent {
  final String title;
  final DateTime start;
  final Duration duration;
  final String tag;

  const ScheduleEvent({
    required this.title,
    required this.start,
    required this.duration,
    required this.tag,
  });
}

enum JourneyStepStatus { done, active, pending, locked }

class JourneyStep {
  final String title;
  final String description;
  final String? detail;
  final JourneyStepStatus status;
  final String? actionLabel;

  const JourneyStep({
    required this.title,
    required this.description,
    this.detail,
    required this.status,
    this.actionLabel,
  });
}

class EarnedBadge {
  final String name;
  final bool earned;

  const EarnedBadge({required this.name, required this.earned});
}
