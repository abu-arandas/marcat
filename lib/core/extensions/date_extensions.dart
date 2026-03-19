// lib/core/extensions/date_extensions.dart

import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DateTimeExtensions
// ─────────────────────────────────────────────────────────────────────────────

extension DateTimeExtensions on DateTime {
  /// Short date — e.g. "February 26, 2026".
  String shortDate() => DateFormat.yMMMMd('en').format(this);

  /// Short date + time — e.g. "February 26, 2026  2:35 PM".
  String shortDateTime() => DateFormat.yMMMMd('en').add_jm().format(this);

  /// Time only — e.g. "2:35 PM".
  String timeOnly() => DateFormat.jm('en').format(this);

  /// Marcat receipt format: "26/02/2026 14:35".
  String receiptFormat() => DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// Relative time label — e.g. "Just now", "5 min ago", "3d ago".
  String relativeTime() {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return shortDate();
  }

  /// Returns `true` when this date falls on today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Strips the time component.
  DateTime get dateOnly => DateTime(year, month, day);

  /// Full day name — e.g. "Monday".
  String dayName() => DateFormat.EEEE('en').format(this);

  /// ISO 8601 UTC string for API calls.
  String get isoString => toUtc().toIso8601String();

  /// Short date using the device's default locale.
  String toDeviceShortDate() => DateFormat.yMd().format(this);
}

// ─────────────────────────────────────────────────────────────────────────────
// NullableDateExtensions
// ─────────────────────────────────────────────────────────────────────────────

extension NullableDateExtensions on DateTime? {
  /// Returns `"—"` when null, otherwise delegates to [shortDate].
  String shortDateOrDash() => this == null ? '—' : this!.shortDate();
}
