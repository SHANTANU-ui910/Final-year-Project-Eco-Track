import 'package:flutter/material.dart';

/// EcoTrack Elite Climate-Fintech Design Tokens
/// Strict adherence to WCAG AA, Plus Jakarta Sans, and vehicle-specific color semantics.
class EcoDesignTokens {
  // Brand Palette (Light Mode)
  static const Color deepEmerald = Color(0xFF073B2E);
  static const Color primary = Color(0xFF0F6B4A);
  static const Color bright = Color(0xFF3FA34D);
  static const Color limeGlow = Color(0xFFB9F36B);
  static const Color mintBg = Color(0xFFEEF8F2);
  static const Color ink = Color(0xFF0D2B22);
  static const Color muted = Color(0xFF5D7A6E);
  static const Color border = Color(0xFFD4E6DC);
  static const Color error = Color(0xFFD64545);
  static const Color success = Color(0xFF1E9E5A);

  // Dark Theme Palette
  static const Color darkBg = Color(0xFF06120E);
  static const Color darkSurface = Color(0xFF0C2019);
  static const Color darkBorder = Color(0xFF16382C);
  static const Color darkInk = Color(0xFFF8FAFC);
  static const Color darkMuted = Color(0xFF94A3B8);

  // Vehicle-Specific Accents & Sky Aura Tints
  static const Color scootyCoral = Color(0xFFF06A5B);
  static const Color bikeAmber = Color(0xFFF2A900);
  static const Color carEmerald = Color(0xFF0F6B4A);
  static const Color busSky = Color(0xFF2F80ED);

  // Gradients per vehicle mode
  static const LinearGradient scootyTint = LinearGradient(
    colors: [Color(0xFFF06A5B), Color(0xFFFF8A7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bikeTint = LinearGradient(
    colors: [Color(0xFFF2A900), Color(0xFFFFC72C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient carTint = LinearGradient(
    colors: [Color(0xFF0F6B4A), Color(0xFF1DB954)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient busTint = LinearGradient(
    colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass Surfaces
  static const Color surfaceGlassLight = Color(0xD1FFFFFF); // 82% white
  static const Color surfaceGlassDark = Color(0xB80C2019);  // 72% dark

  // Radii
  static const double radiusCard = 28.0;
  static const double radiusTile = 20.0;
  static const double radiusButton = 18.0;
  static const double radiusPill = 999.0;

  // Layered Elevation Shadows
  static List<BoxShadow> get cardElevation => [
        BoxShadow(
          color: const Color(0xFF073B2E).withValues(alpha: 0.05),
          offset: const Offset(0, 16),
          blurRadius: 36,
          spreadRadius: -4,
        ),
        BoxShadow(
          color: const Color(0xFF073B2E).withValues(alpha: 0.03),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get heroElevation => [
        BoxShadow(
          color: const Color(0xFF073B2E).withValues(alpha: 0.08),
          offset: const Offset(0, 20),
          blurRadius: 44,
          spreadRadius: -6,
        ),
        BoxShadow(
          color: const Color(0xFF073B2E).withValues(alpha: 0.04),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  // Tabular Numerals FontFeature to eliminate micro-jitter
  static const List<FontFeature> tabularFeatures = [FontFeature.tabularFigures()];

  // Typography Specifications (Plus Jakarta Sans)
  static TextStyle heroSpeed({bool isDark = false}) => TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 56.0,
        height: 60 / 56,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        fontFeatures: tabularFeatures,
        color: isDark ? darkInk : ink,
      );

  static TextStyle statNumber({bool isDark = false}) => TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 24.0,
        height: 28 / 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        fontFeatures: tabularFeatures,
        color: isDark ? darkInk : ink,
      );

  static TextStyle title({bool isDark = false}) => TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16.0,
        height: 22 / 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: isDark ? darkInk : ink,
      );

  static TextStyle label({bool isDark = false}) => TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12.0,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: isDark ? darkMuted : muted,
      );

  static TextStyle caption({bool isDark = false}) => TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12.0,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
        color: isDark ? darkMuted : muted,
      );

  /// Dynamic emission color semantics derived purely from numeric value
  static Color getEmissionColor(double kgCo2e) {
    if (kgCo2e <= 0.0001) {
      return bright; // Neutral, non-alarming green at zero
    } else if (kgCo2e < 0.5) {
      return const Color(0xFF65A30D); // Lime-green
    } else if (kgCo2e < 1.5) {
      return const Color(0xFFF59E0B); // Amber warning
    } else {
      return error; // Red high-emission alert
    }
  }

  /// Vehicle-specific max velocity scale for arc gauge
  static double getVehicleGaugeMax(String modeKey) {
    switch (modeKey.toLowerCase()) {
      case 'scooty':
        return 60.0;
      case 'bike':
        return 100.0;
      case 'bus':
        return 100.0;
      case 'car':
      default:
        return 140.0;
    }
  }

  /// Vehicle accent color lookup
  static Color getVehicleAccent(String modeKey) {
    switch (modeKey.toLowerCase()) {
      case 'scooty':
        return scootyCoral;
      case 'bike':
        return bikeAmber;
      case 'bus':
        return busSky;
      case 'car':
      default:
        return carEmerald;
    }
  }
}
