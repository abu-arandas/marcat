// lib/core/extensions/currency_extensions.dart

extension CurrencyExtensions on num {
  /// Format as Jordanian Dinar: "JD 12.500"
  String toJOD() => 'JD ${toStringAsFixed(3)}';

  /// Compact JOD value without prefix: "12.500"
  String toJODValue() => toStringAsFixed(3);

  /// Arabic JOD format: "12.500 د.أ"
  String toJODArabic() => '${toStringAsFixed(3)} د.أ';

  /// Convert loyalty points to JOD (100 pts = 1 JOD).
  double pointsToJOD() => this / 100;

  /// Convert JOD to loyalty points (1 JOD = 1 pt, floored).
  int jodToPoints() => floor();

  bool get isZero => this == 0;
  bool get isPositive => this > 0;
}

extension NullableCurrencyExtensions on num? {
  String toJODOrFree() {
    if (this == null || this == 0) return 'Free';
    return this!.toJOD();
  }
}
