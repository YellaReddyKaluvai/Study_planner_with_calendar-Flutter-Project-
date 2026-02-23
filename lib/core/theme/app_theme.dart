import 'package:flutter/material.dart';
import 'color_palette.dart';
import 'typography.dart';

class AppTheme {
  static const Color primary = AppPalette.primary;
  static const Color secondary = AppPalette.secondary;
  static const Color background = AppPalette.backgroundDark;

  static const Color surface = AppPalette.surfaceDark;
  static const Color success = AppPalette.success;
  static const Color error = AppPalette.error;
  static const Color warning = AppPalette.warning;
  static const Color glassWhite = AppPalette.glassWhite;
  static final Color glassBorder = Colors.white.withOpacity(0.2);
  
  // Additional colors for compatibility
  static const Color bgCard = AppPalette.surfaceDark;
  static const Color bgDark = AppPalette.backgroundDark;
  static const Color neonCyan = Color(0xFF00F0FF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppPalette.primary, AppPalette.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppPalette.primary,
      scaffoldBackgroundColor: AppPalette.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppPalette.primary,
        secondary: AppPalette.secondary,
        surface: AppPalette.surfaceLight,
        error: AppPalette.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppPalette.textPrimaryLight,
        onError: Colors.white,
      ),
      textTheme: AppTypography.lightTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.lightTextTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppPalette.textPrimaryLight),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        labelStyle: TextStyle(color: AppPalette.textSecondaryLight),
        hintStyle:
            TextStyle(color: AppPalette.textSecondaryLight.withOpacity(0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.lightTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppPalette.primary,
      scaffoldBackgroundColor: AppPalette.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppPalette.primary,
        secondary: AppPalette.secondary,
        surface: AppPalette.surfaceDark,
        error: AppPalette.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppPalette.textPrimaryDark,
        onError: Colors.white,
      ),
      textTheme: AppTypography.darkTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.darkTextTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppPalette.textPrimaryDark),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.error),
        ),
        labelStyle: TextStyle(color: AppPalette.textSecondaryDark),
        hintStyle:
            TextStyle(color: AppPalette.textSecondaryDark.withOpacity(0.7)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.darkTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
