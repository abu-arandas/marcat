import '/config/exports.dart';

class AppTheme {
  static Color mutedGold = const Color(0xFF7F6549);
  static Color deepBronze = const Color(0xFF715A41);
  static Color richBrownGold = const Color(0xFF7F664B);

  static ThemeData theme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: mutedGold,
    cardColor: deepBronze,
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(16),
      labelStyle: const TextStyle(fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: richBrownGold,
        foregroundColor: Colors.white,
        iconColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: richBrownGold,
      ),
    ),
  );
}
