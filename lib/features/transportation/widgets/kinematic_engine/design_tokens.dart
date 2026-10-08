import 'package:flutter/material.dart';

/// Supported vehicle modules for the Kinematic Vehicle Engine.
enum VehicleModule {
  scooty,
  car,
  bike,
  bus,
}

/// Design tokens defining colors, gradients, dimensions, and shadows per vehicle module.
class ModuleThemeTokens {
  final VehicleModule module;
  final String displayName;
  final Color primaryAccent;
  final Color secondaryAccent;
  final LinearGradient skyGradient;
  final Color sunGlowColor;
  final Color sunGlowOuter;
  final LinearGradient bodyGradient;
  final Color bodyHighlightColor;
  final Color bodyUndersideColor;
  final LinearGradient glassGradient;
  final Color glassGlareColor;
  final Color headlightBeamColor;
  final Color taillightGlowColor;
  final Color roadSurfaceColor;
  final Color laneMarkerGlowColor;
  final Color atmosphericParticleColor;
  final Color speedLineColor;
  final LinearGradient cardBackground;
  final Color cardBorderColor;
  final List<BoxShadow> cardShadows;

  const ModuleThemeTokens({
    required this.module,
    required this.displayName,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.skyGradient,
    required this.sunGlowColor,
    required this.sunGlowOuter,
    required this.bodyGradient,
    required this.bodyHighlightColor,
    required this.bodyUndersideColor,
    required this.glassGradient,
    required this.glassGlareColor,
    required this.headlightBeamColor,
    required this.taillightGlowColor,
    required this.roadSurfaceColor,
    required this.laneMarkerGlowColor,
    required this.atmosphericParticleColor,
    required this.speedLineColor,
    required this.cardBackground,
    required this.cardBorderColor,
    required this.cardShadows,
  });

  /// Factory providing consistent, luxury tokens tailored to each vehicle module.
  static ModuleThemeTokens of(VehicleModule module) {
    switch (module) {
      case VehicleModule.scooty:
        return const ModuleThemeTokens(
          module: VehicleModule.scooty,
          displayName: 'Scooty',
          primaryAccent: Color(0xFF00BFA5), // Fresh Mint Teal
          secondaryAccent: Color(0xFF64FFDA),
          skyGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F7FA), Color(0xFFF1FBF8), Color(0xFFFFFFFF)],
          ),
          sunGlowColor: Color(0x3300BFA5),
          sunGlowOuter: Color(0x0000BFA5),
          bodyGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF48DFBC), Color(0xFF00A88F), Color(0xFF00796B)],
          ),
          bodyHighlightColor: Color(0x80E0F7FA),
          bodyUndersideColor: Color(0xFF004D40),
          glassGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x99B2DFDB), Color(0x4480CBC4)],
          ),
          glassGlareColor: Color(0xAAFFFFFF),
          headlightBeamColor: Color(0x55E0F2F1),
          taillightGlowColor: Color(0xFFFF5252),
          roadSurfaceColor: Color(0xFFD8ECE4),
          laneMarkerGlowColor: Color(0xCC00BFA5),
          atmosphericParticleColor: Color(0x5500BFA5),
          speedLineColor: Color(0x3300BFA5),
          cardBackground: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFCFEFD), Color(0xFFF5FAF7)],
          ),
          cardBorderColor: Color(0xFFD6EDE3),
          cardShadows: [
            BoxShadow(
              color: Color(0x14004D40),
              offset: Offset(0, 10),
              blurRadius: 28,
              spreadRadius: -4,
            ),
          ],
        );

      case VehicleModule.car:
        return const ModuleThemeTokens(
          module: VehicleModule.car,
          displayName: 'Car',
          primaryAccent: Color(0xFF2E7D32), // Deep Emerald Forest
          secondaryAccent: Color(0xFF43A047),
          skyGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFF3FAF4), Color(0xFFFFFFFF)],
          ),
          sunGlowColor: Color(0x3343A047),
          sunGlowOuter: Color(0x0043A047),
          bodyGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF1B5E20), Color(0xFF0A3D14)],
          ),
          bodyHighlightColor: Color(0x88C8E6C9),
          bodyUndersideColor: Color(0xFF06230C),
          glassGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x99A5D6A7), Color(0x4481C784)],
          ),
          glassGlareColor: Color(0xBBFFFFFF),
          headlightBeamColor: Color(0x66E8F5E9),
          taillightGlowColor: Color(0xFFFF1744),
          roadSurfaceColor: Color(0xFFD9EADB),
          laneMarkerGlowColor: Color(0xCC43A047),
          atmosphericParticleColor: Color(0x5543A047),
          speedLineColor: Color(0x3343A047),
          cardBackground: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFCFEFD), Color(0xFFF4F9F5)],
          ),
          cardBorderColor: Color(0xFFD5E8D8),
          cardShadows: [
            BoxShadow(
              color: Color(0x1602493E),
              offset: Offset(0, 10),
              blurRadius: 28,
              spreadRadius: -4,
            ),
          ],
        );

      case VehicleModule.bike:
        return const ModuleThemeTokens(
          module: VehicleModule.bike,
          displayName: 'Bike',
          primaryAccent: Color(0xFFFF6F00), // Sunset Amber Flame
          secondaryAccent: Color(0xFFFFAB00),
          skyGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFF9F2), Color(0xFFFFFFFF)],
          ),
          sunGlowColor: Color(0x33FF6F00),
          sunGlowOuter: Color(0x00FF6F00),
          bodyGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB300), Color(0xFFE65100), Color(0xFFBF360C)],
          ),
          bodyHighlightColor: Color(0x99FFE082),
          bodyUndersideColor: Color(0xFF3E1700),
          glassGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x88FFE0B2), Color(0x33FFCC80)],
          ),
          glassGlareColor: Color(0xCCFFFFFF),
          headlightBeamColor: Color(0x66FFF8E1),
          taillightGlowColor: Color(0xFFFF3D00),
          roadSurfaceColor: Color(0xFFEADFD4),
          laneMarkerGlowColor: Color(0xCCFF6F00),
          atmosphericParticleColor: Color(0x55FF6F00),
          speedLineColor: Color(0x33FF6F00),
          cardBackground: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFDFB), Color(0xFFFAF6F2)],
          ),
          cardBorderColor: Color(0xFFEFE2D6),
          cardShadows: [
            BoxShadow(
              color: Color(0x18793300),
              offset: Offset(0, 10),
              blurRadius: 28,
              spreadRadius: -4,
            ),
          ],
        );

      case VehicleModule.bus:
        return const ModuleThemeTokens(
          module: VehicleModule.bus,
          displayName: 'Bus',
          primaryAccent: Color(0xFF0288D1), // Sky Cyan Cerulean
          secondaryAccent: Color(0xFF29B6F6),
          skyGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1F5FE), Color(0xFFF0F9FD), Color(0xFFFFFFFF)],
          ),
          sunGlowColor: Color(0x330288D1),
          sunGlowOuter: Color(0x000288D1),
          bodyGradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFF0277BD), Color(0xFF01579B)],
          ),
          bodyHighlightColor: Color(0x88B3E5FC),
          bodyUndersideColor: Color(0xFF002F6C),
          glassGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x9981D4FA), Color(0x444FC3F7)],
          ),
          glassGlareColor: Color(0xCCFFFFFF),
          headlightBeamColor: Color(0x66E1F5FE),
          taillightGlowColor: Color(0xFFFF1744),
          roadSurfaceColor: Color(0xFFD6E4EB),
          laneMarkerGlowColor: Color(0xCC0288D1),
          atmosphericParticleColor: Color(0x550288D1),
          speedLineColor: Color(0x330288D1),
          cardBackground: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAFDFF), Color(0xFFF2F8FB)],
          ),
          cardBorderColor: Color(0xFFD1E5EE),
          cardShadows: [
            BoxShadow(
              color: Color(0x16013654),
              offset: Offset(0, 10),
              blurRadius: 28,
              spreadRadius: -4,
            ),
          ],
        );
    }
  }
}

