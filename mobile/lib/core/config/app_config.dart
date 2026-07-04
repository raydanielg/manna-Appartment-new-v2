import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl {
    final url = dotenv.env['API_BASE_URL'];
    return url ?? 'https://app.manna.co.tz/api/v1';
  }

  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static bool get isDevelopment => appEnv == 'development';

  static const String mobilePlatformHeader = 'mobile';
}
