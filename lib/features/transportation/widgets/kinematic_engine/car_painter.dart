import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Renders the luxury aerodynamic coupe with multi-layered specular paint,
/// panoramic glasshouse with glare sweep, turbine alloy wheels, and laser lights.
class CarPainter extends CustomPainter {
  final ModuleThemeTokens tokens;
  final double wheelAngle;
  final double idleBob;
  final double taillightPulse; // 0.0 -> 1.0
  final double glareSweepPhase; // 0.0 -> 1.0 across glare window

  static final Paint _paint = Paint()..isAntiAlias = true;
  static final Paint _glowPaint = Paint()
    ..isAntiAlias = true
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
  static final Paint _headlightBeamPaint = Paint()
    ..isAntiAlias = true
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

  CarPainter({
    required this.tokens,
    required this.wheelAngle,
    required this.idleBob,
    required this.taillightPulse,
    required this.glareSweepPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    final cx = size.width * 0.48;
    final cy = size.height * 0.68 + idleBob;
    canvas.translate(cx, cy);

    // 1. Forward Headlight Projection Beam on Road
    _drawHeadlightBeam(canvas);

    // 2. Aerodynamic Coupe Body & Sculpted Side Panels
    _drawCarBody(canvas);

    // 3. Panoramic Glasshouse & Pillars with Reflection Glare
    _drawGlasshouse(canvas);

    // 4. Precision Aero Side Mirror
    _drawSideMirror(canvas);

    // 5. Dual Alloy Wheels (Rear & Front)
    _drawWheel(canvas, const Offset(-46, 12), wheelAngle);
    _drawWheel(canvas, const Offset(46, 12), wheelAngle);

    // 6. Laser Headlights & Continuous LED Tail Strip
    _drawOpticLights(canvas);

    canvas.restore();
  }

  void _drawHeadlightBeam(Canvas canvas) {
    final beamPath = Path()
      ..moveTo(64, -2)
      ..lineTo(145, 10)
      ..lineTo(135, 26)
      ..lineTo(60, 6)
      ..close();

    _headlightBeamPaint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        tokens.headlightBeamColor,
        tokens.headlightBeamColor.withValues(alpha: 0.0),
      ],
    ).createShader(const Rect.fromLTWH(60, -2, 85, 28));

    canvas.drawPath(beamPath, _headlightBeamPaint);
  }

  void _drawCarBody(Canvas canvas) {
    const bodyRect = Rect.fromLTWH(-72, -26, 144, 40);

    // 1. Sleek Coupe Silhouette Profile Path
    final bodyPath = Path()
      ..moveTo(-68, 6)
      ..lineTo(-68, -4)
      ..cubicTo(-66, -12, -54, -14, -40, -14) // Rear decklid / boot
      ..cubicTo(-26, -26, -6, -28, 14, -26) // Fastback roofline
      ..cubicTo(30, -20, 46, -13, 56, -9) // Raked bonnet / hood
      ..cubicTo(66, -7, 68, 0, 68, 6) // Front nose & bumper
      ..lineTo(58, 6)
      // Front wheel arch cutout
      ..arcToPoint(
        const Offset(34, 6),
        radius: const Radius.circular(15),
        clockwise: false,
      )
      ..lineTo(-34, 6)
      // Rear wheel arch cutout
      ..arcToPoint(
        const Offset(-58, 6),
        radius: const Radius.circular(15),
        clockwise: false,
      )
      ..close();

    _paint.shader = tokens.bodyGradient.createShader(bodyRect);
    canvas.drawPath(bodyPath, _paint);

    // 2. High-Gloss Specular Shoulder Line Crease
    final shoulderPath = Path()
      ..moveTo(-64, -5)
      ..lineTo(-44, -7)
      ..cubicTo(-10, -7, 24, -6, 64, -3);

    final shoulderPaint = Paint()
      ..color = tokens.bodyHighlightColor
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(shoulderPath, shoulderPaint);

    // 3. Precision Door Shut Line & Aero Rocker Panel
    final doorLine = Path()
      ..moveTo(2, -18)
      ..lineTo(-4, 5);
    final doorPaint = Paint()
      ..color = tokens.bodyUndersideColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(doorLine, doorPaint);

    // Lower Aerodynamic Rocker Panel Skirt
    final skirtPaint = Paint()..color = tokens.bodyUndersideColor;
    canvas.drawRect(const Rect.fromLTWH(-34, 4.5, 68, 2.0), skirtPaint);
  }

  void _drawGlasshouse(Canvas canvas) {
    const glassRect = Rect.fromLTWH(-38, -25, 66, 17);

    // Aerodynamic Window Path
    final glassPath = Path()
      ..moveTo(-34, -13)
      ..cubicTo(-24, -23, -6, -25, 12, -23)
      ..lineTo(26, -13)
      ..close();

    _paint.shader = tokens.glassGradient.createShader(glassRect);
    canvas.drawPath(glassPath, _paint);

    // B-Pillar Structural Divider
    final pillarPaint = Paint()
      ..color = const Color(0xFF14201C)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(-3, -24), const Offset(-5, -13), pillarPaint);

    // Diagonal Dynamic Glare Sweep
    if (glareSweepPhase > 0.0 && glareSweepPhase < 1.0) {
      canvas.save();
      canvas.clipPath(glassPath);

      final sweepX = -44.0 + (glareSweepPhase * 80.0);
      final glarePaint = Paint()
        ..color = tokens.glassGlareColor.withValues(
          alpha: math.sin(glareSweepPhase * math.pi) * 0.85,
        )
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(sweepX, -30),
        Offset(sweepX - 16, -8),
        glarePaint,
      );
      canvas.restore();
    }
  }

  void _drawSideMirror(Canvas canvas) {
    // Sculpted aerodynamic mirror cap
    final mirrorPaint = Paint()..color = tokens.primaryAccent;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, -15, 8, 4),
        const Radius.circular(2),
      ),
      mirrorPaint,
    );

    // Subtle Amber Indicator Bar
    final indPaint = Paint()..color = const Color(0xFFFFB300);
    canvas.drawRect(const Rect.fromLTWH(19, -13.5, 6, 1.0), indPaint);
  }

  void _drawWheel(Canvas canvas, Offset center, double angle) {
    const outerR = 14.5;
    const rimR = 10.5;

    // Dark Performance Rubber Tyre
    final tyrePaint = Paint()..color = const Color(0xFF19221F);
    canvas.drawCircle(center, outerR, tyrePaint);

    // Inner Rim Shadow Rim
    final innerRimShadow = Paint()..color = const Color(0xFF101614);
    canvas.drawCircle(center, rimR, innerRimShadow);

    // Metallic Gradient Alloy Face
    final rimPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFECEFF1), Color(0xFF90A4AE), Color(0xFF37474F)],
      ).createShader(Rect.fromCircle(center: center, radius: rimR));
    canvas.drawCircle(center, rimR - 0.8, rimPaint);

    // Sculpted Directional Turbine Multi-Spoke Pattern
    final spokePaint = Paint()
      ..color = const Color(0xFF263238)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final a = angle + (i * (math.pi / 3));
      final p2 = Offset(center.dx + math.cos(a) * (rimR - 1.5),
          center.dy + math.sin(a) * (rimR - 1.5));
      canvas.drawLine(center, p2, spokePaint);
    }

    // Precision Center Wheel Hub Cap
    final centerCap = Paint()..color = tokens.secondaryAccent;
    canvas.drawCircle(center, 2.2, centerCap);
  }

  void _drawOpticLights(Canvas canvas) {
    // Projector Headlight Lens
    final headlampPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(62, -4, 5, 6),
        const Radius.circular(2),
      ),
      headlampPaint,
    );

    // Continuous Pulse Tail Lamp Strip
    final pulseAlpha = (0.6 + (taillightPulse * 0.4)).clamp(0.0, 1.0);
    _glowPaint.color = tokens.taillightGlowColor.withValues(alpha: pulseAlpha);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-71, -5, 6, 8),
        const Radius.circular(2),
      ),
      _glowPaint,
    );

    final tailCorePaint = Paint()
      ..color = Colors.white.withValues(alpha: pulseAlpha);
    canvas.drawRect(const Rect.fromLTWH(-69, -3.5, 2.2, 5), tailCorePaint);
  }

  @override
  bool shouldRepaint(covariant CarPainter oldDelegate) {
    return oldDelegate.wheelAngle != wheelAngle ||
        oldDelegate.idleBob != idleBob ||
        oldDelegate.taillightPulse != taillightPulse ||
        oldDelegate.glareSweepPhase != glareSweepPhase ||
        oldDelegate.tokens != tokens;
  }
}

