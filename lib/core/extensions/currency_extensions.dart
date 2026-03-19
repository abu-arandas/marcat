// lib/core/extensions/currency_extensions.dart

extension CurrencyExtensions on num {
  /// Formats as Jordanian Dinar — e.g. "JD 12.500".
  String toJOD() => 'JD ${toStringAsFixed(3)}';

  /// Compact JOD value without prefix — e.g. "12.500".
  String toJODValue() => toStringAsFixed(3);

  /// Converts loyalty points to JOD (100 pts = 1 JOD).
  double pointsToJOD() => this / 100;

  /// Converts JOD to loyalty points (1 JOD = 1 pt, floored).
  int jodToPoints() => floor();

  /// Returns `true` when the value is exactly zero.
  bool get isZero => this == 0;

  /// Returns `true` when the value is greater than zero.
  bool get isPositive => this > 0;
}

extension NullableCurrencyExtensions on num? {
  /// Returns `"Free"` when null or zero, otherwise delegates to [toJOD].
  String toJODOrFree() {
    if (this == null || this == 0) return 'Free';
    return this!.toJOD();
  }
}
