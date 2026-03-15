// lib/controllers/locale_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  static const _prefKey = 'marcat_locale';
  static const _defaultLocale = Locale('en');
  static const _supportedLocales = [Locale('en'), Locale('ar')];

  // Observable locale used by GetMaterialApp via GetBuilder<LocaleController>.
  // Initialised to English; overwritten in onInit() once SharedPreferences loads.
  Locale _locale = _defaultLocale;
  Locale get locale => _locale;

  /// True when the current locale is Arabic (RTL).
  bool get isArabic => _locale.languageCode == 'ar';

  /// True when the current locale is English (LTR).
  bool get isEnglish => _locale.languageCode == 'en';

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      final resolved = _resolve(saved);
      if (resolved != _locale) {
        _locale = resolved;
        update(); // triggers GetBuilder<LocaleController> rebuild
      }
    }
  }

  Future<void> _persist(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, languageCode);
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Switches the app locale to [languageCode] (e.g. 'en' or 'ar').
  /// No-op if [languageCode] is already active or not supported.
  Future<void> switchTo(String languageCode) async {
    final target = _resolve(languageCode);
    if (target == _locale) return;
    _locale = target;
    update(); // rebuilds GetMaterialApp via GetBuilder
    await _persist(languageCode);
  }

  /// Toggles between English and Arabic.
  Future<void> toggle() async {
    await switchTo(isArabic ? 'en' : 'ar');
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Resolves [languageCode] to a supported Locale, falling back to English.
  Locale _resolve(String languageCode) {
    return _supportedLocales.firstWhere(
      (l) => l.languageCode == languageCode,
      orElse: () => _defaultLocale,
    );
  }

  /// Human-readable label for the current locale (for UI display).
  String get currentLanguageLabel => isArabic ? 'العربية' : 'English';

  /// Label for the opposite locale (shown on a "switch language" button).
  String get oppositeLanguageLabel => isArabic ? 'English' : 'العربية';
}
