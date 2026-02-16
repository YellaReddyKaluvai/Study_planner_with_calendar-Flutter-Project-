import 'package:flutter/material.dart';

class AppTheme {
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonPink = Color(0xFFFF00FF);
  static const Color bgDark = Color(0xFF050816);
  static const Color bgCard = Color(0xFF0B1220);

  static ThemeData darkNeonTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: neonCyan,
      secondary: neonPink,
      surface: bgCard,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: Colors.white70,
        fontSize: 14,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonCyan,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    cardTheme: CardThemeData(
  color: AppTheme.bgCard.withOpacity(0.95),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),
  elevation: 12,
  shadowColor: AppTheme.neonCyan.withOpacity(0.3),
),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: neonCyan.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: neonCyan, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
    ),
  );
}
