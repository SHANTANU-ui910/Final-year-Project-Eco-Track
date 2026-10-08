import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Renders the layered parallax environment, sky gradient, glowing sun orb,
/// atmospheric dust motes, glowing speed lines, and reflective road surface.
class ScenePainter extends CustomPainter {
  final ModuleThemeTokens tokens;
  final double parallaxProgress; // Continual 0.0 -> 1.0 driving layer motion
  final double idleBobOffset; // Subtle vertical float offset
  final bool isReducedMotion;

  // Cached paint objects for zero allocation 60fps rendering
  static final Paint _skyPaint = Paint()..isAntiAlias = true;
  static final Paint _sunPaint = Paint()..isAntiAlias = true;
  static final Paint _skylinePaint = Paint()..isAntiAlias = true;
  static final Paint _midgroundPaint = Paint()..isAntiAlias = true;
  static final Paint _roadPaint = Paint()..isAntiAlias = true;
  static final Paint _laneMarkerPaint = Paint()..isAntiAlias = true;
  static final Paint _particlePaint = Paint()..isAntiAlias = true;
  static final Paint _speedLinePaint = Paint()..isAntiAlias = true;
  static final Paint _shadowPaint = Paint()
    ..isAntiAlias = true
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
  static final Paint _reflectionPaint = Paint()
    ..isAntiAlias = true
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

  ScenePainter({
    required this.tokens,
    required this.parallaxProgress,
    required this.idleBobOffset,
    this.isReducedMotion = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final roadY = h * 0.74;

    // 1. Vertical Sky Gradient
    _drawSky(canvas, Rect.fromLTWH(0, 0, w, h));

    // 2. Ambient Radiant Sun Glow Orb
    _drawSunOrb(canvas, Offset(w * 0.52, h * 0.44));

    // 3. Parallax Layer 1: Distant Skyline Silhouettes (0.12x speed)
    _drawDistantSkyline(canvas, w, roadY);

    // 4. Parallax Layer 2: Mid-ground Soft Foliage & Transit Poles (0.3x speed)
    _drawMidground(canvas, w, roadY);

    // 5. Atmospheric Floating Light Dust Motes
    _drawAtmosphereParticles(canvas, w, roadY);

    // 6. Dynamic Motion Speed Lines
    _drawSpeedLines(canvas, w, roadY);

    // 7. Smooth Asphalt Road Surface with Edge Fade
    _drawRoadSurface(canvas, w, roadY, h - roadY);

    // 8. Glowing Dashed Lane Markers (1.0x speed)
    _drawLaneMarkers(canvas, w, roadY + 12);

    // 9. Ground Contact: Soft Elliptical Shadow & Ambient Reflection
    _drawGroundContact(canvas, Offset(w * 0.48, roadY + 5));
  }

  void _drawSky(Canvas canvas, Rect rect) {
    _skyPaint.shader = tokens.skyGradient.createShader(rect);
    canvas.drawRect(rect, _skyPaint);
  }

  void _drawSunOrb(Canvas canvas, Offset center) {
    const glowRadius = 88.0;
    _sunPaint.shader = RadialGradient(
      colors: [tokens.sunGlowColor, tokens.sunGlowOuter],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: glowRadius));
    canvas.drawCircle(center, glowRadius, _sunPaint);
  }

  void _drawDistantSkyline(Canvas canvas, double w, double roadY) {
    final offset = isReducedMotion ? 0.0 : (parallaxProgress * 0.12 * w) % w;
    _skylinePaint.color = tokens.primaryAccent.withValues(alpha: 0.10);

    final path = Path();
    final skylineBaseY = roadY - 18;

    for (int rep = -1; rep <= 1; rep++) {
      final startX = rep * w - offset;
      path.moveTo(startX, roadY);
      path.lineTo(startX, skylineBaseY);
      path.lineTo(startX + w * 0.08, skylineBaseY);
      path.lineTo(startX + w * 0.08, skylineBaseY - 14);
      path.lineTo(startX + w * 0.18, skylineBaseY - 14);
      path.lineTo(startX + w * 0.18, skylineBaseY);
      path.lineTo(startX + w * 0.28, skylineBaseY);
      path.lineTo(startX + w * 0.33, skylineBaseY - 22);
      path.lineTo(startX + w * 0.42, skylineBaseY - 22);
      path.lineTo(startX + w * 0.45, skylineBaseY);
      path.lineTo(startX + w * 0.58, skylineBaseY);
      path.lineTo(startX + w * 0.62, skylineBaseY - 16);
      path.lineTo(startX + w * 0.72, skylineBaseY - 16);
      path.lineTo(startX + w * 0.76, skylineBaseY);
      path.lineTo(startX + w * 0.88, skylineBaseY - 26);
      path.lineTo(startX + w * 0.94, skylineBaseY - 26);
      path.lineTo(startX + w, skylineBaseY);
      path.lineTo(startX + w, roadY);
    }
    path.close();
    canvas.drawPath(path, _skylinePaint);
  }

  void _drawMidground(Canvas canvas, double w, double roadY) {
    final offset = isReducedMotion ? 0.0 : (parallaxProgress * 0.3 * w) % w;
    _midgroundPaint.color = tokens.primaryAccent.withValues(alpha: 0.16);

    final path = Path();
    final treeBaseY = roadY - 4;

    for (int rep = -1; rep <= 1; rep++) {
      final startX = rep * w - offset;
      path.moveTo(startX, roadY);

      // Stylized gentle rolling hillocks and transit poles
      path.quadraticBezierTo(
        startX + w * 0.2,
        treeBaseY - 12,
        startX + w * 0.4,
        treeBaseY,
      );
      path.quadraticBezierTo(
        startX + w * 0.65,
        treeBaseY - 18,
        startX + w * 0.85,
        treeBaseY,
      );
      path.lineTo(startX + w, roadY);
    }
    path.close();
    canvas.drawPath(path, _midgroundPaint);
  }

  void _drawAtmosphereParticles(Canvas canvas, double w, double roadY) {
    _particlePaint.color = tokens.atmosphericParticleColor;

    // 10 deterministic floating particles
    for (int i = 0; i < 10; i++) {
      final speedFactor = 0.15 + (i % 3) * 0.1;
      final xSeed = (i * 37.0) % w;
      final ySeed = 25.0 + ((i * 19.0) % (roadY - 45.0));

      final x = isReducedMotion
          ? xSeed
          : (xSeed - (parallaxProgress * speedFactor * w)) % w;
      final y = ySeed + math.sin((parallaxProgress * 2 * math.pi) + i) * 3.0;
      final radius = 1.0 + (i % 3) * 0.6;

      canvas.drawCircle(Offset(x < 0 ? x + w : x, y), radius, _particlePaint);
    }
  }

  void _drawSpeedLines(Canvas canvas, double w, double roadY) {
    if (isReducedMotion) return;
    _speedLinePaint
      ..color = tokens.speedLineColor
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final baseLeft = w * 0.22;
    for (int i = 0; i < 4; i++) {
      final y = roadY - 20 - (i * 12.0) + math.sin(parallaxProgress * 8 + i) * 1.5;
      final linePhase = (parallaxProgress * 2.5 + i * 0.25) % 1.0;
      final startX = baseLeft - (linePhase * 60.0);
      final length = 18.0 + (i * 6.0);

      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + length, y),
        _speedLinePaint,
      );
    }
  }

  void _drawRoadSurface(Canvas canvas, double w, double roadY, double roadH) {
    final rect = Rect.fromLTWH(0, roadY, w, roadH);

    // Lateral fade from transparent -> rich road color -> transparent
    _roadPaint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      stops: const [0.0, 0.08, 0.92, 1.0],
      colors: [
        tokens.roadSurfaceColor.withValues(alpha: 0.0),
        tokens.roadSurfaceColor,
        tokens.roadSurfaceColor,
        tokens.roadSurfaceColor.withValues(alpha: 0.0),
      ],
    ).createShader(rect);

    canvas.drawRect(rect, _roadPaint);

    // Soft asphalt horizon baseline
    final baselinePaint = Paint()
      ..color = tokens.primaryAccent.withValues(alpha: 0.22)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, roadY), Offset(w, roadY), baselinePaint);
  }

  void _drawLaneMarkers(Canvas canvas, double w, double markerY) {
    _laneMarkerPaint
      ..color = tokens.laneMarkerGlowColor
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const dashWidth = 18.0;
    const dashGap = 20.0;
    const cycle = dashWidth + dashGap;
    final offset = isReducedMotion ? 0.0 : (parallaxProgress * cycle) % cycle;

    for (double x = -dashWidth - offset; x < w + dashWidth; x += cycle) {
      if (x + dashWidth > 15 && x < w - 15) {
        // Fade lane dashes smoothly near card edges
        final edgeAlpha = (x < 60)
            ? (x / 60.0).clamp(0.0, 1.0)
            : (x > w - 60)
                ? ((w - x) / 60.0).clamp(0.0, 1.0)
                : 1.0;

        _laneMarkerPaint.color = tokens.laneMarkerGlowColor.withValues(
          alpha: tokens.laneMarkerGlowColor.a * edgeAlpha,
        );
        canvas.drawLine(Offset(x, markerY), Offset(x + dashWidth, markerY), _laneMarkerPaint);
      }
    }
  }

  void _drawGroundContact(Canvas canvas, Offset center) {
    // 1. Soft Elliptical Ground Shadow
    final shadowRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 3.0),
      width: 140.0,
      height: 14.0,
    );
    _shadowPaint.color = tokens.bodyUndersideColor.withValues(alpha: 0.35);
    canvas.drawOval(shadowRect, _shadowPaint);

    // 2. Faint Ground Color Ambient Pool
    final reflectionRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 6.0),
      width: 110.0,
      height: 10.0,
    );
    _reflectionPaint.color = tokens.primaryAccent.withValues(alpha: 0.18);
    canvas.drawOval(reflectionRect, _reflectionPaint);
  }

  @override
  bool shouldRepaint(covariant ScenePainter oldDelegate) {
    return oldDelegate.parallaxProgress != parallaxProgress ||
        oldDelegate.idleBobOffset != idleBobOffset ||
        oldDelegate.tokens != tokens;
  }
}
