import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  static Future<void> setString(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, value);
  }

  static Future<void> remove(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final prefs = await _instance;
    await prefs.clear();
  }
}
