import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idioma de la app (español / inglés), guardado en SharedPreferences.
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('es')) {
    _load();
  }

  static const String _key = 'languageCode';
  static const List<String> supportedCodes = ['es', 'en'];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'es';
    if (!mounted) return;
    state = Locale(supportedCodes.contains(code) ? code : 'es');
  }

  Future<void> changeLanguage(String code) async {
    if (!supportedCodes.contains(code)) return;
    state = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }
}
