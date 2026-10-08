import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.forestGreen,
      scaffoldBackgroundColor: AppColors.offWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.forestGreen,
        secondary: AppColors.sage,
        surface: AppColors.pureWhite,
        error: AppColors.alertRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.charcoal,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.offWhite,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.charcoal),
      ),
      cardTheme: CardThemeData(
        color: AppColors.pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderGray, width: 0.8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderGray,
        thickness: 0.8,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.sage,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.sage,
        secondary: AppColors.softSage,
        surface: AppColors.darkSurface,
        error: AppColors.alertRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.offWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.offWhite),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 0.8,
        space: 1,
      ),
    );
  }
}

