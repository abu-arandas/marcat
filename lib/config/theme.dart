import '/config/exports.dart';

class AppTheme {
  static Color mutedGold = const Color(0xFF7F6549);
  static Color deepBronze = const Color(0xFF715A41);
  static Color richBrownGold = const Color(0xFF7F664B);
  static Color accentGold = const Color(0xFFF5C16C);
  static Color accentBlack = Colors.black;

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
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
            return accentGold;
          }
          return richBrownGold;
        }),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        overlayColor: MaterialStateProperty.all<Color>(accentGold.withOpacity(0.15)),
        iconColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        elevation: MaterialStateProperty.all<double>(2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
            return accentBlack;
          }
          return richBrownGold;
        }),
        backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
            return accentGold.withOpacity(0.08);
          }
          return null;
        }),
        side: MaterialStateProperty.resolveWith<BorderSide>((states) {
          if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
            return BorderSide(color: accentGold, width: 2);
          }
          return BorderSide(color: richBrownGold, width: 1.5);
        }),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.hovered) || states.contains(MaterialState.pressed)) {
            return accentGold;
          }
          return richBrownGold;
        }),
        overlayColor: MaterialStateProperty.all<Color>(accentGold.withOpacity(0.08)),
      ),
    ),
  );
}
