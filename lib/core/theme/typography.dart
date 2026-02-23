import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_palette.dart';

class AppTypography {
  static TextTheme get lightTextTheme => GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: AppPalette.textPrimaryLight,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: AppPalette.textPrimaryLight,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppPalette.textPrimaryLight,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppPalette.textPrimaryLight,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimaryLight,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimaryLight,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimaryLight,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimaryLight,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppPalette.textPrimaryLight,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppPalette.textPrimaryLight,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppPalette.textPrimaryLight,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppPalette.textSecondaryLight,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppPalette.textPrimaryLight,
          letterSpacing: 0.1,
        ),
      );

  static TextTheme get darkTextTheme => GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: AppPalette.textPrimaryDark,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: AppPalette.textPrimaryDark,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppPalette.textPrimaryDark,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppPalette.textPrimaryDark,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimaryDark,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimaryDark,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimaryDark,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimaryDark,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppPalette.textPrimaryDark,
          letterSpacing: 0.1,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppPalette.textPrimaryDark,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppPalette.textPrimaryDark,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppPalette.textSecondaryDark,
          letterSpacing: 0.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppPalette.textPrimaryDark,
          letterSpacing: 0.1,
        ),
      );
}
