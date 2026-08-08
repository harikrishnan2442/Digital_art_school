enum ModuleType { video, theory, practice }

enum ModuleStatus { done, active, locked }

class CourseModule {
  final int number;
  final String title;
  final String description;
  final ModuleType type;
  final int durationMinutes;
  final ModuleStatus status;

  const CourseModule({
    required this.number,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    required this.status,
  });
}

class Resource {
  final String title;
  final String subtitle;
  final ModuleType type;

  const Resource({
    required this.title,
    required this.subtitle,
    required this.type,
  });
}
