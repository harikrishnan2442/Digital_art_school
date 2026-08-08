/// Mirrors the `students` table from `database_schema.sql`.
/// When connected to the real PHP API (see `StudentApiService`), an
/// instance of this is the actual row from MySQL. `AppState` holds
/// the current one in memory for the life of the app session.
class Student {
  int? studentId; // null until the server assigns one (i.e. before register() returns)
  String fullName;
  String email;
  String password; // never populated from the server — see toJson/fromJson
  int? age;
  String? location;

  // Art selection & interests
  String? artCategory;
  String? artDiscipline;
  String? secondaryInterest;

  // Experience & background
  SkillLevel? skillLevel;
  double? yearsOfExperience;
  String? previousTraining;

  // Learning goals & schedule
  LearningPurpose? learningPurpose;
  String? timeCommitment;
  String? preferredSchedule;
  String? specificGoals;

  // Health & accessibility (optional)
  String? physicalConstraints;
  String? learningAccommodations;

  // Derived / system-ish fields
  DateTime registrationDate;
  DateTime? lastLogin;
  int? teacherId;
  String? teacherName;

  Student({
    this.studentId,
    required this.fullName,
    required this.email,
    required this.password,
    this.age,
    this.location,
    this.artCategory,
    this.artDiscipline,
    this.secondaryInterest,
    this.skillLevel,
    this.yearsOfExperience,
    this.previousTraining,
    this.learningPurpose,
    this.timeCommitment,
    this.preferredSchedule,
    this.specificGoals,
    this.physicalConstraints,
    this.learningAccommodations,
    DateTime? registrationDate,
    this.lastLogin,
    this.teacherId,
    this.teacherName,
  }) : registrationDate = registrationDate ?? DateTime.now();

  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'ST';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  bool get hasTeacher => teacherId != null;

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'fullName': fullName,
        'email': email,
        'password': password,
        'age': age,
        'location': location,
        'artCategory': artCategory,
        'artDiscipline': artDiscipline,
        'secondaryInterest': secondaryInterest,
        'skillLevel': skillLevel?.name,
        'yearsOfExperience': yearsOfExperience,
        'previousTraining': previousTraining,
        'learningPurpose': learningPurpose?.name,
        'timeCommitment': timeCommitment,
        'preferredSchedule': preferredSchedule,
        'specificGoals': specificGoals,
        'physicalConstraints': physicalConstraints,
        'learningAccommodations': learningAccommodations,
        'registrationDate': registrationDate.toIso8601String(),
        'lastLogin': lastLogin?.toIso8601String(),
        'teacherId': teacherId,
        'teacherName': teacherName,
      };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        studentId: json['studentId'] as int?,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        password: (json['password'] as String?) ?? '',
        age: json['age'] as int?,
        location: json['location'] as String?,
        artCategory: json['artCategory'] as String?,
        artDiscipline: json['artDiscipline'] as String?,
        secondaryInterest: json['secondaryInterest'] as String?,
        skillLevel: _skillLevelFromName(json['skillLevel'] as String?),
        yearsOfExperience: (json['yearsOfExperience'] as num?)?.toDouble(),
        previousTraining: json['previousTraining'] as String?,
        learningPurpose: _learningPurposeFromName(json['learningPurpose'] as String?),
        timeCommitment: json['timeCommitment'] as String?,
        preferredSchedule: json['preferredSchedule'] as String?,
        specificGoals: json['specificGoals'] as String?,
        physicalConstraints: json['physicalConstraints'] as String?,
        learningAccommodations: json['learningAccommodations'] as String?,
        registrationDate: json['registrationDate'] != null
            ? DateTime.tryParse(json['registrationDate'] as String)
            : null,
        lastLogin: json['lastLogin'] != null
            ? DateTime.tryParse(json['lastLogin'] as String)
            : null,
        teacherId: json['teacherId'] as int?,
        teacherName: json['teacherName'] as String?,
      );

  static SkillLevel? _skillLevelFromName(String? name) {
    if (name == null) return null;
    for (final v in SkillLevel.values) {
      if (v.name == name) return v;
    }
    return null;
  }

  static LearningPurpose? _learningPurposeFromName(String? name) {
    if (name == null) return null;
    for (final v in LearningPurpose.values) {
      if (v.name == name) return v;
    }
    return null;
  }
}

enum SkillLevel { completeBeginner, basic, intermediate, advanced }

extension SkillLevelLabel on SkillLevel {
  String get label {
    switch (this) {
      case SkillLevel.completeBeginner:
        return 'Complete Beginner';
      case SkillLevel.basic:
        return 'Basic';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
    }
  }
}

enum LearningPurpose { hobby, professional, performance, certification, therapy }

extension LearningPurposeLabel on LearningPurpose {
  String get label {
    switch (this) {
      case LearningPurpose.hobby:
        return 'Hobby / Personal Interest';
      case LearningPurpose.professional:
        return 'Professional Career';
      case LearningPurpose.performance:
        return 'Performance & Competitions';
      case LearningPurpose.certification:
        return 'Certification';
      case LearningPurpose.therapy:
        return 'Therapy / Wellbeing';
    }
  }
}
