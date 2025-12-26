import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    _loadLocale();
    return null;
  }

  static const _kLocaleKey = 'selected_locale';

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    if (code != null) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      prefs.remove(_kLocaleKey);
    } else {
      prefs.setString(_kLocaleKey, locale.languageCode);
    }
  }

  // Helper to map language names
  static String getLanguageName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'Inglés';
      case 'pt':
        return 'Portugués';
      case 'fr':
        return 'Francés';
      case 'de':
        return 'Alemán';
      case 'it':
        return 'Italiano';
      case 'ru':
        return 'Ruso';
      case 'zh':
        return 'Chino (Simplificado)';
      case 'ja':
        return 'Japonés';
      case 'ko':
        return 'Coreano';
      case 'ar':
        return 'Árabe';
      case 'hi':
        return 'Hindi';
      case 'tr':
        return 'Turco';
      case 'id':
        return 'Indonesio';
      case 'vi':
        return 'Vietnamita';
      default:
        return 'Español';
    }
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, Locale?>(
  LanguageNotifier.new,
);
