import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/teacher.dart';

/// Loads the real 26-teacher dataset bundled at
/// `assets/data/teachers.json` (the same file also used by the
/// optional `php_api_additions/migrations/seed_teachers.php` script if
/// you choose to load it into MySQL too).
///
/// Cached after the first load — call [load] once at startup (see
/// `AppState.restoreSession`) and read [teachers] anywhere after that.
class TeacherRepository {
  TeacherRepository._();

  static List<Teacher> _teachers = [];
  static List<Teacher> get teachers => _teachers;
  static bool _loaded = false;

  static Future<List<Teacher>> load() async {
    if (_loaded) return _teachers;
    try {
      final raw = await rootBundle.loadString('assets/data/teachers.json');
      final decoded = jsonDecode(raw) as List<dynamic>;
      _teachers = decoded
          .map((e) => Teacher.fromJson(e as Map<String, dynamic>))
          .where((t) => t.isActive)
          .toList();
    } catch (_) {
      // Missing/corrupt asset shouldn't crash the app — the teacher
      // list just comes back empty and screens should handle that.
      _teachers = [];
    }
    _loaded = true;
    return _teachers;
  }
}
