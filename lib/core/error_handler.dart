// lib/core/error_handler.dart

import 'package:get/get.dart';

import 'utils/snackbar_utils.dart';

/// Converts low-level Supabase / Dart errors into typed [AppException]s,
/// logs them, and shows a styled Snackbar.
class ErrorHandler {
  ErrorHandler._();

  static AppException handle(Object error, StackTrace? stackTrace) {
    AppException appException;

    if (error is AppException) {
      appException = error;
    } else {
      appException =
          AppException(message: error.toString(), originalError: error);
    }

    SnackbarUtils.showError(Get.context!, appException.message);
    return appException;
  }
}

/// Base exception class for all Marcat application errors.
class AppException implements Exception {
  const AppException({required this.message, this.code, this.originalError});

  final String message;
  final String? code;
  final Object? originalError;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}
