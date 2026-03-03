import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Riverpod provider for app language/locale
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en', 'US')) {
    _loadSavedLocale();
  }

  static const _prefKey = 'app_locale';

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null) {
        final parts = saved.split('_');
        if (parts.length >= 2) {
          state = Locale(parts[0], parts[1]);
        }
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, '${locale.languageCode}_${locale.countryCode}');
    } catch (_) {}
  }

  /// Available languages map: display name → Locale
  static const Map<String, Locale> availableLanguages = {
    'English': Locale('en', 'US'),
    'हिंदी (Hindi)': Locale('hi', 'IN'),
    'Español': Locale('es', 'ES'),
    'Français': Locale('fr', 'FR'),
    'Deutsch': Locale('de', 'DE'),
    '中文': Locale('zh', 'CN'),
    'عربي': Locale('ar', 'SA'),
    '日本語': Locale('ja', 'JP'),
    'Português': Locale('pt', 'BR'),
    '한국어': Locale('ko', 'KR'),
  };

  String get currentLanguageName {
    for (final entry in availableLanguages.entries) {
      if (entry.value.languageCode == state.languageCode) {
        return entry.key;
      }
    }
    return 'English';
  }
}
