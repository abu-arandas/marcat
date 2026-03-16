// lib/core/error_handler.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'utils/snackbar_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ErrorHandler
// ─────────────────────────────────────────────────────────────────────────────

/// Converts low-level Supabase / Dart errors into typed [AppException]s,
/// logs them, and optionally shows a styled Snackbar.
///
/// ## showSnackbar (default: false)
/// Pass `showSnackbar: true` at call sites where no other error UI is shown
/// (e.g. background data loads).  Leave it false — the default — for screens
/// that display inline error widgets, to avoid showing two error messages.
class ErrorHandler {
  ErrorHandler._();

  static AppException handle(
    Object error,
    StackTrace? stackTrace, {
    bool showSnackbar = false,
  }) {
    AppException appException;

    if (error is AppException) {
      appException = error;
    } else {
      appException = AppException(
        message: _humanise(error),
        originalError: error,
      );
    }

    // Always log in debug mode so developers see the full trace.
    if (kDebugMode) {
      debugPrint('[ErrorHandler] ${appException.message}');
      if (stackTrace != null) debugPrint(stackTrace.toString());
    }

    if (showSnackbar) {
      final ctx = Get.context;
      if (ctx != null) {
        SnackbarUtils.showError(ctx, appException.message);
      } else {
        Get.snackbar(
          'Error',
          appException.message,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    }

    return appException;
  }

  /// Converts raw exception messages into user-friendly strings.
  static String _humanise(Object error) {
    final raw = error.toString();
    // Supabase / PostgreSQL duplicate key
    if (raw.contains('duplicate key') || raw.contains('23505')) {
      return 'This record already exists.';
    }
    // Supabase foreign key
    if (raw.contains('foreign key') || raw.contains('23503')) {
      return 'This operation references a record that does not exist.';
    }
    // Network / timeout
    if (raw.contains('SocketException') || raw.contains('TimeoutException')) {
      return 'Network error. Please check your connection and try again.';
    }
    return raw;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppException
// ─────────────────────────────────────────────────────────────────────────────

/// Base exception class for all Marcat application errors.
class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  final String message;
  final String? code;
  final Object? originalError;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}
