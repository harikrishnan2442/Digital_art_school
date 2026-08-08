import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Loads GROQ_API_KEY from the .env file at the project root for the
  // AI Learning Assistant. Missing/empty is handled gracefully by
  // GroqService — the app still runs, the chat just explains it needs
  // a key.
  try {
    await dotenv.load(fileName: '.env');
    debugPrint("API_BASE_URL = ${dotenv.env['API_BASE_URL']}");
    debugPrint('✅ .env loaded successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Failed to load .env');
    debugPrint(e.toString());
    debugPrint(stackTrace.toString());
  }

  runApp(const DigitalArtSchoolApp());
}
