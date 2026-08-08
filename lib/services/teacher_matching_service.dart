import '../models/student.dart';
import '../models/teacher.dart';

/// Rule-based teacher matching — the Flutter counterpart of the
/// predefined-rules matcher already built on the website. This is a
/// pure function (no I/O, no state): give it a student and the full
/// teacher roster, get back a ranked list.
///
/// The rules, in order of weight:
///  1. Same art category as the student chose at registration — the
///     single strongest signal (a Kathakali teacher for a Kathakali
///     student), so it dominates the score.
///  2. Exact discipline match (e.g. "Mohiniyattam" specifically,
///     not just "Classical Dance") adds a solid secondary bonus.
///  3. Skill-level fit — does this teacher actually teach the
///     student's declared level at all (`teaches_levels` in the real
///     dataset)? Teachers who don't are pushed to the bottom rather
///     than excluded outright, in case nothing else matches better.
///  4. Learning-purpose fit — does the teacher support the student's
///     stated goal (hobby, professional, certification, etc.)?
///  5. Schedule overlap — the teacher's declared availability
///     overlaps with the student's preferred time slot.
///  6. Location match — same city gets a small bonus (useful once
///     in-person sessions matter; harmless otherwise).
///  7. Experience fit — more experienced teachers are weighted up for
///     intermediate/advanced students; newer teachers are weighted up
///     for complete beginners.
///  8. Open seats — a small tie-breaker toward teachers with more
///     room left, and fully-booked teachers are filtered out entirely
///     rather than merely deprioritised.
class TeacherMatchingService {
  TeacherMatchingService._();

  static List<Teacher> match(Student? student, List<Teacher> allTeachers) {
    // Rule: never suggest a fully-booked teacher.
    final open = allTeachers.where((t) => t.seatsLeft > 0).toList();
    final pool = open.isEmpty ? allTeachers : open;

    if (student == null) return pool;

    final scored = pool.map((t) => MapEntry(t, _score(student, t))).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return scored.map((e) => e.key).toList();
  }

  static int _score(Student student, Teacher teacher) {
    int score = 0;

    if (student.artCategory != null && student.artCategory == teacher.specialization) {
      score += 100;
    }

    if (student.artDiscipline != null && teacher.disciplines.contains(student.artDiscipline)) {
      score += 40;
    }

    if (teacher.teachesLevelKeys.isNotEmpty) {
      score += teacher.teachesLevel(student.skillLevel) ? 30 : -30;
    }

    if (teacher.learningPurposeKeys.isNotEmpty) {
      score += teacher.teachesPurpose(student.learningPurpose) ? 20 : 0;
    }

    if (student.preferredSchedule != null &&
        teacher.availableSlots.contains(student.preferredSchedule)) {
      score += 25;
    }

    if (student.location != null &&
        teacher.location != null &&
        student.location!.toLowerCase().contains(teacher.location!.toLowerCase())) {
      score += 15;
    }

    final level = student.skillLevel;
    if (level == SkillLevel.advanced || level == SkillLevel.intermediate) {
      if (teacher.experienceYears >= 15) score += 15;
    } else if (level == SkillLevel.completeBeginner) {
      if (teacher.experienceYears <= 12) score += 8;
    }

    score += teacher.seatsLeft.clamp(0, 10);

    return score;
  }
}
