import 'package:flutter/material.dart';

/// EcoTrack Brand Palette sampled directly from the official logo
/// "Small Steps. Big Impact."
class AppColors {
  AppColors._();

  // Primary Brand Colors from Logo
  static const Color brandDeepTeal = Color(0xFF0D5C53);    // 'Eco' deep teal green
  static const Color brandVibrantGreen = Color(0xFF43A047); // 'Track' bright leaf green
  static const Color brandLimeAccent = Color(0xFF7CB342);   // Toes & highlights
  static const Color brandGlobeCyan = Color(0xFF26A69A);    // Earth globe blue-green
  static const Color brandPaleGreen = Color(0xFFE8F5E9);    // Background badge tints

  // Secondary & Accents
  static const Color forestGreen = Color(0xFF0D5C53);
  static const Color sage = Color(0xFF43A047);
  static const Color softSage = Color(0xFF66BB6A);
  static const Color paleSage = Color(0xFFE8F5E9);
  static const Color mintAccent = Color(0xFF81C784);

  // Clean Neutrals
  static const Color charcoal = Color(0xFF1E2927);
  static const Color offWhite = Color(0xFFF9FBF9);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color warmGray = Color(0xFF60726E);
  static const Color lightGray = Color(0xFFEDF2EE);
  static const Color borderGray = Color(0xFFD6E2D8);

  // Status & Alerts
  static const Color alertRed = Color(0xFFE53935);
  static const Color warningAmber = Color(0xFFFB8C00);

  // Dark Mode specific tones
  static const Color darkBg = Color(0xFF0A1613);
  static const Color darkSurface = Color(0xFF122420);
  static const Color darkCard = Color(0xFF19322D);
  static const Color darkBorder = Color(0xFF264A42);
}
