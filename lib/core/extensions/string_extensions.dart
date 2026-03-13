// lib/core/extensions/string_extensions.dart

extension StringExtensions on String {
  /// Capitalise the first character.
  String get capitalised {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalise every word.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((w) => w.isEmpty ? w : w.capitalised).join(' ');
  }

  /// Truncate and append ellipsis if longer than [maxLength].
  String truncate(int maxLength, {String ellipsis = '…'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }

  /// Extract initials from a full name (up to 2 letters).
  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
          .hasMatch(this);

  bool get isValidPhone =>
      RegExp(r'^\+?[0-9]{8,15}$').hasMatch(replaceAll(' ', ''));

  /// Convert a slug-style string to a readable label.
  String get fromSlug => replaceAll('_', ' ').replaceAll('-', ' ').titleCase;

  /// Generate a URL-safe slug (ASCII only; strips Arabic characters).
  String get toSlug => toLowerCase()
      // FIX: was garbled UTF-8 — use Unicode range for Arabic letters
      .replaceAll(RegExp(r'[\u0600-\u06FF]', unicode: true), '')
      .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');

  /// Returns null if blank (empty or whitespace-only).
  String? get nullIfEmpty => trim().isEmpty ? null : this;

  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);
}

extension NullableStringExtensions on String? {
  /// Returns empty string when null.
  String get orEmpty => this ?? '';

  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
}
