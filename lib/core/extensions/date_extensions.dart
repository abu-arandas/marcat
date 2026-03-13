// lib/core/extensions/date_extensions.dart

import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Short date in given locale, e.g. "26 Feb 2026" / "26 فبراير 2026".
  String shortDate(String locale) => DateFormat.yMMMMd(locale).format(this);

  /// Short date + time.
  String shortDateTime(String locale) =>
      DateFormat.yMMMMd(locale).add_jm().format(this);

  /// Time only.
  String timeOnly(String locale) => DateFormat.jm(locale).format(this);

  /// Marcat receipt format: "26/02/2026 14:35"
  String receiptFormat() => DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// Relative time label ("2 hours ago" / "منذ ساعتين").
  String relativeTime(String locale) {
    final now = DateTime.now();
    final diff = now.difference(this);
    final isAr = locale.startsWith('ar');

    if (diff.inSeconds < 60) return isAr ? 'الآن' : 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return isAr ? 'منذ $m دقيقة' : '$m min ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return isAr ? 'منذ $h ساعة' : '${h}h ago';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return isAr ? 'منذ $d أيام' : '${d}d ago';
    }
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return isAr ? 'منذ $w أسبوع' : '${w}w ago';
    }
    return shortDate(locale);
  }

  /// Is this date today?
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Strip time component.
  DateTime get dateOnly => DateTime(year, month, day);

  /// Day name for given locale, e.g. "Monday" / "الاثنين".
  String dayName(String locale) => DateFormat.EEEE(locale).format(this);

  /// ISO 8601 string for API calls.
  String get isoString => toUtc().toIso8601String();

  /// Short date using the device's current locale.
  String toDeviceShortDate() => DateFormat.yMd().format(this);
}

extension NullableDateExtensions on DateTime? {
  /// Returns "—" when null.
  String shortDateOrDash(String locale) {
    if (this == null) return '—';
    return this!.shortDate(locale);
  }
}
