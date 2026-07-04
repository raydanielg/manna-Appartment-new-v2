import 'dart:convert';
import 'package:flutter/services.dart';

class AppStrings {
  static Map<String, dynamic> _strings = {};

  static Future<void> load(String locale) async {
    final json = await rootBundle.loadString('assets/lang/.json');
    _strings = jsonDecode(json);
  }

  static String get(String key) => _strings[key] ?? key;
}
