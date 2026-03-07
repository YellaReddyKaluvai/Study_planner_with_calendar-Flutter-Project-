import 'package:flutter/material.dart';

class AppPalette {
  // Brand Colors - Premium Violet/Indigo (Ultra vibrant)
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF4338CA); // Indigo 700
  static const Color primaryLight = Color(0xFF818CF8); // Indigo 400
  static const Color primaryUltraLight = Color(0xFFA5B4FC); // Indigo 300

  // Secondary / Accent - Teal/Cyan
  static const Color secondary = Color(0xFF14B8A6); // Teal 500
  static const Color secondaryDark = Color(0xFF0F766E); // Teal 700
  static const Color secondaryLight = Color(0xFF2DD4BF); // Teal 400

  // Tertiary - Warm accent for highlights
  static const Color tertiary = Color(0xFFF59E0B); // Amber 500
  static const Color tertiaryLight = Color(0xFFFBBF24); // Amber 400

  // Backgrounds - Light (Premium & clean)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFAFBFC);
  static const Color elevatedLight = Color(0xFFFFFFFF);

  // Backgrounds - Dark (Ultra deep, rich)
  static const Color backgroundDark = Color(0xFF0B0F1A); // Deep navy
  static const Color surfaceDark = Color(0xFF141B2D); // Rich slate
  static const Color cardDark = Color(0xFF1A2235); // Elevated card
  static const Color elevatedDark = Color(0xFF1E293B); // Slate 800

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color textTertiaryLight = Color(0xFF94A3B8); // Slate 400

  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Slate 100
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiaryDark = Color(0xFF64748B); // Slate 500

  // Functional Colors
  static const Color success = Color(0xFF22C55E); // Green 500
  static const Color successLight = Color(0xFF4ADE80); // Green 400
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorLight = Color(0xFFF87171); // Red 400
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Glassmorphism overlays (Ultra)
  static const Color glassWhite = Color(0x33FFFFFF); // 20% White
  static const Color glassWhiteLight = Color(0x1AFFFFFF); // 10% White
  static const Color glassBlack = Color(0x33000000); // 20% Black

  // Vibrant Accent Colors for stat cards & gradients
  static const Color accentPink = Color(0xFFEC4899); // Pink 500
  static const Color accentOrange = Color(0xFFF97316); // Orange 500
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan 500
  static const Color accentPurple = Color(0xFFA855F7); // Purple 500
  static const Color accentRose = Color(0xFFFB7185); // Rose 400
  static const Color accentEmerald = Color(0xFF34D399); // Emerald 400
  static const Color accentSky = Color(0xFF38BDF8); // Sky 400
  static const Color accentViolet = Color(0xFF7C3AED); // Violet 600

  // Premium Gradient pairs
  static const List<Color> gradientPrimary = [primary, primaryLight];
  static const List<Color> gradientSecondary = [secondary, secondaryLight];
  static const List<Color> gradientWarm = [accentOrange, accentRose];
  static const List<Color> gradientCool = [accentCyan, accentSky];
  static const List<Color> gradientPurple = [accentViolet, accentPurple];
  static const List<Color> gradientSuccess = [Color(0xFF059669), successLight];

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000); // 10% Black
  static const Color shadowDark = Color(0x40000000); // 25% Black
  static const Color shadowPrimary = Color(0x406366F1); // 25% Primary
}
