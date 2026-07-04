import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_cache_service.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    final code = await LocalCacheService.getString('app_locale');
    if (code != null && (code == 'en' || code == 'sw')) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'sw') return;
    state = Locale(languageCode);
    await LocalCacheService.setString('app_locale', languageCode);
  }
}
