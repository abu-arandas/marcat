// lib/core/extensions/context_extensions.dart

import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  // ── Theme shortcuts ───────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // ── MediaQuery shortcuts ──────────────────────────────────────────────────
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  double get topPadding => mediaQuery.padding.top;
  double get bottomPadding => mediaQuery.padding.bottom;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  bool get isKeyboardOpen => mediaQuery.viewInsets.bottom > 0;

  // ── Bootstrap-aligned breakpoints ────────────────────────────────────────
  bool get isMobile => screenWidth < 576;
  bool get isTablet => screenWidth >= 576 && screenWidth < 992;
  bool get isDesktop => screenWidth >= 992;

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
}
