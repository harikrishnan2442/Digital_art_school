import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Thrown for anything that goes wrong talking to Groq — missing key,
/// network failure, bad response shape — so the chat UI can show one
/// friendly message instead of a raw stack trace.
class GroqException implements Exception {
  final String message;
  GroqException(this.message);

  @override
  String toString() => message;
}

/// Minimal client for Groq's OpenAI-compatible chat completions
/// endpoint. Put your key in a `.env` file at the project root:
///
/// ```
/// GROQ_API_KEY=gsk_your_key_here
/// ```
///
/// `.env` is already declared as a pubspec asset and loaded in
/// `main.dart` via `flutter_dotenv`, and is listed in `.gitignore` so
/// the key never gets committed.
///
/// Model note: Groq deprecated `llama-3.3-70b-versatile` and
/// `llama-3.1-8b-instant` in June 2026. This defaults to
/// `openai/gpt-oss-20b` (fast + cheap, Groq's recommended replacement
/// for 8B-class use cases) — swap `defaultModel` for
/// `openai/gpt-oss-120b` if you want the larger/smarter model instead.
class GroqService {
  GroqService._();

  static const String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const String defaultModel = 'openai/gpt-oss-20b';

  static String? get _apiKey {
    final key = dotenv.env['GROQ_API_KEY'];
    return (key == null || key.trim().isEmpty) ? null : key.trim();
  }

  static bool get isConfigured => _apiKey != null;

  /// [history] is the running conversation as `{'role': ..., 'content': ...}`
  /// maps, oldest first — `role` is `'user'` or `'assistant'`.
  static Future<String> sendMessage({
    required String systemPrompt,
    required List<Map<String, String>> history,
    String model = defaultModel,
  }) async {
    final apiKey = _apiKey;
    if (apiKey == null) {
      throw GroqException(
        'No Groq API key found. Add GROQ_API_KEY=your_key to the .env '
        'file at the project root, then restart the app.',
      );
    }

    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                ...history,
              ],
              'temperature': 0.6,
              'max_tokens': 600,
            }),
          )
          .timeout(const Duration(seconds: 25));
    } catch (e) {
      throw GroqException('Could not reach Groq — check your internet connection. ($e)');
    }

    if (response.statusCode != 200) {
      String detail = response.body;
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        detail = decoded['error']?['message']?.toString() ?? detail;
      } catch (_) {
        // Leave `detail` as the raw body if it isn't JSON.
      }
      throw GroqException('Groq API error (${response.statusCode}): $detail');
    }

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw GroqException('Groq returned an empty response.');
      }
      final message = choices.first['message'] as Map<String, dynamic>;
      final content = message['content'] as String?;
      return (content ?? '').trim();
    } catch (e) {
      throw GroqException('Could not parse the response from Groq. ($e)');
    }
  }
}
