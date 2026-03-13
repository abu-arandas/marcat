// lib/core/utils/validators.dart

/// Collection of form validators returning null on success or an error string.
class Validators {
  Validators._();

  static String? requiredField(String? value, {String? label}) {
    if (value == null || value.trim().isEmpty) {
      return label != null ? '$label is required' : 'This field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String? original) {
    return (String? value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != original) return 'Passwords do not match';
      return null;
    };
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.length < min) {
      return 'Must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? value, int max) {
    if (value != null && value.length > max) {
      return 'Must be at most $max characters';
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    final n = num.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return 'Must be greater than zero';
    return null;
  }

  static String? nonNegativeNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    final n = num.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 0) return 'Must be zero or greater';
    return null;
  }

  static String? percentage(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    final n = num.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < 0 || n > 100) return 'Must be between 0 and 100';
    return null;
  }

  static String? sku(String? value) {
    if (value == null || value.trim().isEmpty) return 'SKU is required';
    if (!RegExp(r'^[A-Za-z0-9_\-]+$').hasMatch(value.trim())) {
      return 'SKU may only contain letters, numbers, hyphens, and underscores';
    }
    return null;
  }

  static String? hexColor(String? value) {
    if (value == null || value.trim().isEmpty) return 'Color is required';
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(value.trim())) {
      return 'Enter a valid hex color (e.g. #B8962E)';
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    try {
      final uri = Uri.parse(value.trim());
      if (!uri.isAbsolute) return 'Enter a valid URL';
    } catch (_) {
      return 'Enter a valid URL';
    }
    return null;
  }

  /// Chain multiple validators.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final v in validators) {
        final result = v(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
