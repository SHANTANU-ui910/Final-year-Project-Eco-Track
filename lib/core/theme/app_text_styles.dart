import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Clean typography hierarchy using Inter / SF Pro aesthetic
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppColors.charcoal,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.charcoal,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.charcoal,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.charcoal,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        color: AppColors.charcoal,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.charcoal,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AppColors.warmGray,
      );

  static TextStyle get metricHuge => GoogleFonts.inter(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}

