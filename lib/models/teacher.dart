import 'student.dart';

/// Mirrors the extended teacher dataset you shared (26 teachers across
/// 6 specializations) — see `assets/data/teachers.json` and
/// `TeacherRepository`. A basic subset of these fields also exists in
/// `database_schema.sql`'s `teachers` table; the optional
/// `php_api_additions/migrations` bundle adds the rest as real MySQL
/// columns if you want this fully live instead of bundled.
class Teacher {
  final int id;
  final String name;
  final String email;
  final String specialization;
  final List<String> disciplines;
  final int experienceYears;
  final String bio;
  final int maxStudents;
  final int currentStudents;
  final bool isActive;

  /// Raw slot keys like 'weekday_evening' — matches
  /// `Student.preferredSchedule` for the matching engine.
  final List<String> availableSlots;

  /// Raw skill-level keys like 'complete_beginner' — matches
  /// `SkillLevel.name` conventions once translated, used to check
  /// whether a teacher teaches a given student's level at all.
  final List<String> teachesLevelKeys;

  /// Raw learning-purpose keys — these already match
  /// `LearningPurpose.name` values 1:1 ('hobby', 'professional', …).
  final List<String> learningPurposeKeys;

  final double? rating;
  final String? location;
  final List<String> timeSlots;
  final List<String> languages;
  final int? minCommitmentHrs;

  const Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
    required this.disciplines,
    required this.experienceYears,
    required this.bio,
    required this.maxStudents,
    required this.currentStudents,
    this.isActive = true,
    this.availableSlots = const [],
    this.teachesLevelKeys = const [],
    this.learningPurposeKeys = const [],
    this.rating,
    this.location,
    this.timeSlots = const [],
    this.languages = const [],
    this.minCommitmentHrs,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    List<String> stringList(dynamic value) =>
        value is List ? value.map((e) => e.toString()).toList() : <String>[];

    return Teacher(
      id: json['teacher_id'] as int,
      name: json['teacher_name'] as String,
      email: json['email'] as String,
      specialization: json['specialization'] as String,
      disciplines: stringList(json['art_disciplines']),
      experienceYears: (json['experience_years'] as num).toInt(),
      bio: json['bio'] as String? ?? '',
      maxStudents: (json['max_students'] as num).toInt(),
      currentStudents: (json['current_students'] as num).toInt(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      availableSlots: stringList(json['available_schedules']),
      teachesLevelKeys: stringList(json['teaches_levels']),
      learningPurposeKeys: stringList(json['learning_purposes']),
      rating: (json['rating'] as num?)?.toDouble(),
      location: json['location'] as String?,
      timeSlots: stringList(json['time_slots']),
      languages: stringList(json['languages']),
      minCommitmentHrs: (json['min_commitment_hrs'] as num?)?.toInt(),
    );
  }

  String get initials {
    final parts = name
        .replaceAll(RegExp(r'^(Dr\.|Prof\.|Smt\.|Sri\.)\s*'), '')
        .trim()
        .split(RegExp(r'\s+'));
    if (parts.length < 2) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  int get seatsLeft => (maxStudents - currentStudents).clamp(0, maxStudents);

  bool teachesLevel(SkillLevel? level) {
    if (level == null) return true;
    return teachesLevelKeys.contains(_skillLevelKey(level));
  }

  bool teachesPurpose(LearningPurpose? purpose) {
    if (purpose == null) return true;
    return learningPurposeKeys.contains(purpose.name);
  }

  static String _skillLevelKey(SkillLevel level) {
    switch (level) {
      case SkillLevel.completeBeginner:
        return 'complete_beginner';
      case SkillLevel.basic:
        return 'basic';
      case SkillLevel.intermediate:
        return 'intermediate';
      case SkillLevel.advanced:
        return 'advanced';
    }
  }
}

enum RequestStatus { pending, accepted, rejected }

class TeacherRequest {
  final Teacher teacher;
  final String message;
  RequestStatus status;
  final DateTime requestDate;
  int? serverRequestId; // set once teacher_request.php confirms the insert

  TeacherRequest({
    required this.teacher,
    required this.message,
    this.status = RequestStatus.pending,
    DateTime? requestDate,
    this.serverRequestId,
  }) : requestDate = requestDate ?? DateTime.now();
}
