import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../data/teacher_repository.dart';
import '../services/api_client.dart';
import '../services/student_api_service.dart';
import '../services/teacher_matching_service.dart';

const _kStudentKey = 'das_current_student';
const _kRememberMeKey = 'das_remember_me';
const _kThemeModeKey = 'das_theme_mode';

/// Single source of truth for the whole app session.
///
/// When `API_BASE_URL` is set in `.env`, login/register/teacher
/// requests hit your real PHP API + MySQL database (see
/// `php_api_additions/`) and every screen shows real data. Without it,
/// the app quietly falls back to a local demo mode so it's still
/// explorable out of the box — see [isUsingLiveApi].
///
/// Either way, everything downstream (dashboard, profile, settings…)
/// reads from here via `context.watch<AppState>()`.
///
/// Session + theme preference persist across app restarts via
/// `shared_preferences` — see [restoreSession] and [toggleTheme].
class AppState extends ChangeNotifier {
  Student? _student;
  Student? get student => _student;
  bool get isLoggedIn => _student != null;

  /// True once `API_BASE_URL` is set in `.env` — see `ApiClient`.
  bool get isUsingLiveApi => ApiClient.isConfigured;

  bool _isRestoring = true;
  bool get isRestoring => _isRestoring;

  bool _rememberMe = false;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  final List<TeacherRequest> _requests = [];
  List<TeacherRequest> get requests => List.unmodifiable(_requests);

  // Settings toggles (Theme & Display / Notifications / Privacy tabs)
  bool darkModeFollowSystem = true;
  bool emailNotifications = true;
  bool sessionReminders = true;
  bool communityDigest = false;
  bool profileVisibleToTeachers = true;
  bool showProgressPublicly = false;

  void setDarkModeFollowSystem(bool v) {
    darkModeFollowSystem = v;
    notifyListeners();
  }

  void setEmailNotifications(bool v) {
    emailNotifications = v;
    notifyListeners();
  }

  void setSessionReminders(bool v) {
    sessionReminders = v;
    notifyListeners();
  }

  void setCommunityDigest(bool v) {
    communityDigest = v;
    notifyListeners();
  }

  void setProfileVisibleToTeachers(bool v) {
    profileVisibleToTeachers = v;
    notifyListeners();
  }

  void setShowProgressPublicly(bool v) {
    showProgressPublicly = v;
    notifyListeners();
  }

  // ---------------------------------------------------------------
  // Startup: restore a remembered session + saved theme preference,
  // load the teacher catalogue, and (if live) refresh the student's
  // profile from the server. Call this once, before the first frame
  // that depends on it — the splash screen awaits it while its
  // animation plays.
  // ---------------------------------------------------------------
  Future<void> restoreSession() async {
    // Independent of login state, so it's always ready.
    await TeacherRepository.load();

    try {
      final prefs = await SharedPreferences.getInstance();

      final savedTheme = prefs.getString(_kThemeModeKey);
      if (savedTheme == 'dark') _themeMode = ThemeMode.dark;
      if (savedTheme == 'light') _themeMode = ThemeMode.light;

      final rememberMe = prefs.getBool(_kRememberMeKey) ?? false;
      _rememberMe = rememberMe;
      if (rememberMe) {
        final raw = prefs.getString(_kStudentKey);
        if (raw != null) {
          _student = Student.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        }
      }

      // If we have a live server and a cached student with a real id,
      // quietly refresh from the database so edits made elsewhere
      // (or directly in phpMyAdmin) show up. Falls back to the
      // cached copy if the server can't be reached right now.
      if (isUsingLiveApi && _student?.studentId != null) {
        try {
          _student = await StudentApiService.fetchProfile(_student!.studentId!);
        } catch (_) {
          // Offline or server down — keep the cached copy.
        }
      }
    } catch (_) {
      // Corrupt or unavailable local storage shouldn't block startup —
      // just fall through to a normal logged-out state.
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeModeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {
      // Non-fatal — the toggle still works for this session.
    }
  }

  Future<void> _persistSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_student != null) {
        await prefs.setString(_kStudentKey, jsonEncode(_student!.toJson()));
      }
    } catch (_) {
      // Non-fatal — the app still works, it just won't remember next launch.
    }
  }

  Future<void> _setRememberMe(bool remember) async {
    _rememberMe = remember;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kRememberMeKey, remember);
      if (!remember) await prefs.remove(_kStudentKey);
    } catch (_) {
      // Non-fatal.
    }
  }

  /// Logs in against the real database when `API_BASE_URL` is set in
  /// `.env`; otherwise falls back to a local demo account so the app
  /// stays explorable without a server. Throws [ApiException] with a
  /// user-facing message on real failures (wrong password, server
  /// unreachable, etc.) — callers should catch and show it.
  ///
  /// [rememberMe]: when true, the session survives closing the app.
  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    if (isUsingLiveApi) {
      _student = await StudentApiService.login(email, password);
    } else {
      _student = Student(
        fullName: 'Anjali Menon',
        email: email.isEmpty ? 'anjali.menon@example.com' : email,
        password: password,
        age: 22,
        location: 'Thiruvananthapuram, Kerala',
        artCategory: 'Classical Dance',
        artDiscipline: 'Mohiniyattam',
        secondaryInterest: 'Mural painting, Carnatic vocals',
        skillLevel: SkillLevel.basic,
        yearsOfExperience: 1.5,
        previousTraining: 'Two years of informal training at a local sabha.',
        learningPurpose: LearningPurpose.hobby,
        timeCommitment: '4-6 hrs / week',
        preferredSchedule: 'weekday_evening',
        specificGoals: 'Build a solid foundation and perform at the annual '
            'college arts fest.',
      );
    }
    await _finishLogin(rememberMe);
  }

  Future<void> _finishLogin(bool rememberMe) async {
    notifyListeners();
    await _setRememberMe(rememberMe);
    if (rememberMe) await _persistSession();
  }

  /// [draft] is the Student built locally by the registration wizard
  /// (no studentId yet). When live, this posts it to the real
  /// database and replaces [draft] with the server's copy (which has
  /// a real studentId). Throws [ApiException] on failure (e.g.
  /// duplicate email) — callers should catch and show it.
  Future<void> registerStudent(Student draft, {bool rememberMe = true}) async {
    if (isUsingLiveApi) {
      _student = await StudentApiService.register(draft);
    } else {
      _student = draft;
    }
    await _finishLogin(rememberMe);
  }

  void updateStudent(void Function(Student s) update) {
    if (_student == null) return;
    update(_student!);
    notifyListeners();
    if (_rememberMe) _persistSession();
  }

  /// Refreshes the current student straight from the database. Useful
  /// as a pull-to-refresh on the profile screen. No-op in demo mode.
  Future<void> refreshProfileFromServer() async {
    if (!isUsingLiveApi || _student?.studentId == null) return;
    _student = await StudentApiService.fetchProfile(_student!.studentId!);
    notifyListeners();
    if (_rememberMe) await _persistSession();
  }

  /// Changes the password via the real API when live; otherwise just
  /// updates the in-memory copy (demo mode).
  Future<void> changePassword(String newPassword) async {
    if (_student == null) return;
    if (isUsingLiveApi && _student!.studentId != null) {
      _student = await StudentApiService.changePassword(_student!.studentId!, newPassword);
    } else {
      _student!.password = newPassword;
    }
    notifyListeners();
    if (_rememberMe) await _persistSession();
  }

  Future<void> logout() async {
    _student = null;
    _requests.clear();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStudentKey);
      await prefs.remove(_kRememberMeKey);
    } catch (_) {
      // Non-fatal.
    }
  }

  /// Sends a request via the real API when live (requires the
  /// teacher to actually exist in your `teachers` table — see the
  /// note in `php_api_additions/api/teacher_request.php`); otherwise
  /// just tracks it locally for the demo. Throws [ApiException] on a
  /// real failure so the UI can show why (e.g. teacher not seeded yet).
  Future<TeacherRequest> sendTeacherRequest(Teacher teacher, String message) async {
    int? serverRequestId;
    if (isUsingLiveApi && _student?.studentId != null) {
      serverRequestId = await StudentApiService.sendTeacherRequest(
        studentId: _student!.studentId!,
        teacherId: teacher.id,
        message: message,
      );
    }
    final request = TeacherRequest(
      teacher: teacher,
      message: message,
      serverRequestId: serverRequestId,
    );
    _requests.add(request);
    notifyListeners();
    return request;
  }

  bool hasPendingRequestFor(Teacher teacher) => _requests
      .any((r) => r.teacher.id == teacher.id && r.status == RequestStatus.pending);

  /// Demo helper: simulate a teacher accepting a request, which is
  /// what flips `student.hasTeacher` to true throughout the app. This
  /// stays local-only even in live mode — accepting a request is a
  /// teacher-side action this student app doesn't perform.
  void simulateAcceptRequest(TeacherRequest request) {
    request.status = RequestStatus.accepted;
    updateStudent((s) {
      s.teacherId = request.teacher.id;
      s.teacherName = request.teacher.name;
    });
  }

  /// Ranked by the rule-based matching engine — see
  /// `lib/services/teacher_matching_service.dart` for the rules.
  /// Sourced from the real 26-teacher dataset via `TeacherRepository`
  /// (bundled as an asset — see its doc comment for how to make it
  /// fully live in MySQL too).
  List<Teacher> get matchedTeachers =>
      TeacherMatchingService.match(_student, TeacherRepository.teachers);
}
