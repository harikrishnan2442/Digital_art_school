import '../models/student.dart';
import 'api_client.dart';

/// Calls the PHP endpoints in `api/` (login.php, register.php,
/// profile.php, teacher_request.php). Each PHP endpoint already
/// returns JSON shaped exactly like `Student.fromJson` expects — see
/// `api/bootstrap.php`'s `studentRowToApiJson()` — so this layer stays
/// thin.
class StudentApiService {
  StudentApiService._();

  static Future<Student> login(String email, String password) async {
    final data = await ApiClient.post('login.php', {
      'email': email,
      'password': password,
    });
    return Student.fromJson(data['student'] as Map<String, dynamic>);
  }

  static Future<Student> register(Student student) async {
    final payload = student.toJson()..remove('registrationDate');
    final data = await ApiClient.post('register.php', payload);
    return Student.fromJson(data['student'] as Map<String, dynamic>);
  }

  static Future<Student> fetchProfile(int studentId) async {
    final data = await ApiClient.get('profile.php', {'student_id': '$studentId'});
    return Student.fromJson(data['student'] as Map<String, dynamic>);
  }

  /// Only send the fields you want changed — `fields` is merged with
  /// `studentId` and posted as a partial update.
  static Future<Student> updateProfile(int studentId, Map<String, dynamic> fields) async {
    final data = await ApiClient.post('profile.php', {
      'studentId': studentId,
      ...fields,
    });
    return Student.fromJson(data['student'] as Map<String, dynamic>);
  }

  static Future<Student> changePassword(int studentId, String newPassword) async {
    final data = await ApiClient.post('profile.php', {
      'studentId': studentId,
      'newPassword': newPassword,
    });
    return Student.fromJson(data['student'] as Map<String, dynamic>);
  }

  static Future<int> sendTeacherRequest({
    required int studentId,
    required int teacherId,
    required String message,
  }) async {
    final data = await ApiClient.post('teacher_request.php', {
      'studentId': studentId,
      'teacherId': teacherId,
      'message': message,
    });
    return data['requestId'] as int;
  }
}
