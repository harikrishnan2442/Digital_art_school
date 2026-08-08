import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Thin wrapper around the PHP API in `api/` (see the
/// `php_api_additions` bundle) — every call goes through here so
/// there's exactly one place that knows about base URLs, timeouts,
/// and how to unwrap `{success, message, data}` responses.
///
/// Base URL comes from `.env` (`API_BASE_URL`), same pattern as the
/// Groq key. Common values:
///   - Android emulator reaching your dev machine: http://10.0.2.2/digital-art-school/api
///   - iOS simulator:                              http://127.0.0.1/digital-art-school/api
///   - Physical device on the same Wi-Fi:           http://<your-LAN-IP>/digital-art-school/api
class ApiClient {
  ApiClient._();

  static String? get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.trim().isEmpty) return null;
    return url.trim().endsWith('/')
        ? url.trim().substring(0, url.trim().length - 1)
        : url.trim();
  }

  static bool get isConfigured => baseUrl != null;

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final base = baseUrl;
    if (base == null) {
      throw ApiException(
        'No API_BASE_URL set in .env — the app doesn\'t know where your '
        'PHP server is. See the README for how to set it.',
      );
    }
    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$base/$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      throw ApiException(
        'Could not reach the server at $base. Is your PHP server running '
        'and is API_BASE_URL correct in .env? ($e)',
      );
    }
    return _unwrap(response);
  }

  static Future<Map<String, dynamic>> get(String path, [Map<String, String>? query]) async {
    final base = baseUrl;
    if (base == null) {
      throw ApiException(
        'No API_BASE_URL set in .env — the app doesn\'t know where your '
        'PHP server is. See the README for how to set it.',
      );
    }
    final uri = Uri.parse('$base/$path').replace(queryParameters: query);
    http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (e) {
      throw ApiException(
        'Could not reach the server at $base. Is your PHP server running '
        'and is API_BASE_URL correct in .env? ($e)',
      );
    }
    return _unwrap(response);
  }

  static Map<String, dynamic> _unwrap(http.Response response) {
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Server returned something unexpected (HTTP ${response.statusCode}).');
    }

    final success = decoded['success'] == true;
    if (!success) {
      throw ApiException((decoded['message'] as String?) ?? 'Request failed.');
    }
    return (decoded['data'] as Map<String, dynamic>?) ?? {};
  }
}
