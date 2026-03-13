// lib/controllers/locale_controller.dart
//
// Absorbs: locale_provider.dart
//
// Delete the old file — this is the canonical locale controller.
// The only behavioural fix vs. the original: Get.updateLocale is now also
// called in _load() so the app locale is correct on cold start.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocalePrefKey = 'marcat_locale';

class LocaleController extends GetxController {
  final locale = const Locale('en').obs;

  bool get isArabic  => locale.value.languageCode == 'ar';
  bool get isEnglish => locale.value.languageCode == 'en';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code  = prefs.getString(_kLocalePrefKey) ?? 'en';
    locale.value = Locale(code);
    Get.updateLocale(locale.value); // FIX: missing in original locale_provider
  }

  Future<void> setLocale(String languageCode) async {
    locale.value = Locale(languageCode);
    Get.updateLocale(locale.value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocalePrefKey, languageCode);
  }

  Future<void> toggle() => setLocale(isEnglish ? 'ar' : 'en');
}
