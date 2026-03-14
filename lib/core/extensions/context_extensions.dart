// lib/core/extensions/context_extensions.dart

import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  // ── Theme shortcuts ───────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // ── Locale ────────────────────────────────────────────────────────────────
  Locale get locale => Localizations.localeOf(this);
  String get localeString => locale.languageCode;
  bool get isArabic => locale.languageCode == 'ar';

  // ── MediaQuery shortcuts ──────────────────────────────────────────────────
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  double get topPadding => mediaQuery.padding.top;
  double get bottomPadding => mediaQuery.padding.bottom;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  bool get isKeyboardOpen => mediaQuery.viewInsets.bottom > 0;

  // ── Layout helpers ────────────────────────────────────────────────────────
  bool get isTablet => screenWidth >= 768;
  bool get isDesktop => screenWidth >= 1200;
  bool get isMobile => screenWidth < 768;

  // ── Navigator ─────────────────────────────────────────────────────────────
  NavigatorState get navigator => Navigator.of(this);

  void pop<T>([T? result]) => navigator.pop(result);

  Future<T?> push<T>(Widget page) =>
      navigator.push<T>(MaterialPageRoute(builder: (_) => page));

  // ── SnackBar ──────────────────────────────────────────────────────────────
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }

  // ── Text direction helpers ────────────────────────────────────────────────
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  Alignment get startAlignment =>
      isArabic ? Alignment.centerRight : Alignment.centerLeft;

  Alignment get endAlignment =>
      isArabic ? Alignment.centerLeft : Alignment.centerRight;
}
