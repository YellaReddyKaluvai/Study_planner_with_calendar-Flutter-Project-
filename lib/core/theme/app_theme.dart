import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Academic Futurism Color Palette
  static const Color primary = Color(0xFF00F0FF); // Cyan Neon
  static const Color secondary = Color(0xFF7B61FF); // Academic Iris
  static const Color background = Color(0xFF0A0E17); // Deep Space
  static const Color surface = Color(0xFF161B28); // Soft Dark
  static const Color error = Color(0xFFFF2E51); // Alert Red
  static const Color success = Color(0xFF00FF94); // Success Green
  static const Color warning = Color(0xFFFFC043); // Warning Amber

  // Glassmorphism Colors
  static Color glassWhite = Colors.white.withOpacity(0.05);
  static Color glassBorder = Colors.white.withOpacity(0.1);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );
  }
}
