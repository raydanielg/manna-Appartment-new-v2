import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8001/api';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static bool get isDevelopment => appEnv == 'development';
}
