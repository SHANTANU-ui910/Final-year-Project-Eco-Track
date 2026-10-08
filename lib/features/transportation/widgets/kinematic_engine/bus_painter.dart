import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Renders the sleek aerodynamic electric transit bus with panoramic continuous glass,
/// illuminated LED destination board, precision door shut lines, and dual commercial wheels.
class BusPainter extends CustomPainter {
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
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9.0);

  BusPainter({
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

    // 1. Broad Forward Headlight Projection Beam
    _drawHeadlightBeam(canvas);

    // 2. Streamlined Monocoque Bus Body & Aerodynamic Roof Pod
    _drawBusBody(canvas);

    // 3. Illuminated LED Destination Display Board
    _drawDestinationBoard(canvas);

    // 4. Panoramic Passenger Glass Row with Glare Sweep
    _drawPanoramicWindows(canvas);

    // 5. Precision Passenger Door Outlines & Side Indicator
    _drawDoorAndDetails(canvas);

    // 6. Heavy-Duty Commercial Wheels (Rear & Front)
    _drawWheel(canvas, const Offset(-52, 12), wheelAngle);
    _drawWheel(canvas, const Offset(52, 12), wheelAngle);

    // 7. High-Intensity Front Projectors & Vertical LED Tail Array
    _drawLights(canvas);

    canvas.restore();
  }

  void _drawHeadlightBeam(Canvas canvas) {
    final beamPath = Path()
      ..moveTo(76, -6)
      ..lineTo(155, 6)
      ..lineTo(145, 26)
      ..lineTo(74, 4)
      ..close();

    _headlightBeamPaint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        tokens.headlightBeamColor,
        tokens.headlightBeamColor.withValues(alpha: 0.0),
      ],
    ).createShader(const Rect.fromLTWH(74, -6, 85, 32));

    canvas.drawPath(beamPath, _headlightBeamPaint);
  }

  void _drawBusBody(Canvas canvas) {
    const bodyRect = Rect.fromLTWH(-80, -32, 160, 44);

    // 1. Sleek Aerodynamic Bus Monocoque Shape
    final bodyPath = Path()
      ..moveTo(-78, 6)
      ..lineTo(-78, -28) // Rear vertical contour
      ..quadraticBezierTo(-76, -32, -68, -32) // Rear roof radius
      ..lineTo(60, -32) // Flat aerodynamic roof line
      ..quadraticBezierTo(74, -31, 78, -16) // Raked aerodynamic front windshield slope
      ..lineTo(78, 2)
      ..quadraticBezierTo(76, 6, 68, 6) // Front chin
      ..lineTo(64, 6)
      // Front wheel arch cutout
      ..arcToPoint(
        const Offset(40, 6),
        radius: const Radius.circular(15),
        clockwise: false,
      )
      ..lineTo(-40, 6)
      // Rear wheel arch cutout
      ..arcToPoint(
        const Offset(-64, 6),
        radius: const Radius.circular(15),
        clockwise: false,
      )
      ..close();

    _paint.shader = tokens.bodyGradient.createShader(bodyRect);
    canvas.drawPath(bodyPath, _paint);

    // 2. Aerodynamic Roof Battery / HVAC Pod Fairing
    final roofPodPath = Path()
      ..moveTo(-35, -32)
      ..quadraticBezierTo(-32, -37, -24, -37)
      ..lineTo(24, -37)
      ..quadraticBezierTo(32, -37, 35, -32)
      ..close();
    final podPaint = Paint()
      ..color = tokens.bodyUndersideColor.withValues(alpha: 0.9);
    canvas.drawPath(roofPodPath, podPaint);

    // 3. Specular Shoulder Accent Line
    final shoulderPath = Path()
      ..moveTo(-74, -12)
      ..lineTo(68, -12);
    final shoulderPaint = Paint()
      ..color = tokens.bodyHighlightColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawPath(shoulderPath, shoulderPaint);

    // Lower Rocker Panel Edge
    final skirtPaint = Paint()..color = tokens.bodyUndersideColor;
    canvas.drawRect(const Rect.fromLTWH(-40, 4.5, 80, 2.2), skirtPaint);
  }

  void _drawDestinationBoard(Canvas canvas) {
    // Glowing Digital Headboard
    const boardRect = Rect.fromLTWH(58, -28, 16, 5);
    final boardBg = Paint()..color = const Color(0xFF0F1A17);
    canvas.drawRRect(RRect.fromRectAndRadius(boardRect, const Radius.circular(1.5)), boardBg);

    // Amber LED Dot Glow
    final ledGlow = Paint()
      ..color = const Color(0xFFFFB300)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(61, -25.5), const Offset(71, -25.5), ledGlow);
  }

  void _drawPanoramicWindows(Canvas canvas) {
    const windowRect = Rect.fromLTWH(-72, -26, 144, 13);
    final windowPath = Path()
      ..addRRect(RRect.fromRectAndRadius(windowRect, const Radius.circular(3)));

    _paint.shader = tokens.glassGradient.createShader(windowRect);
    canvas.drawPath(windowPath, _paint);

    // Individual Window Division Pillars
    final pillarPaint = Paint()
      ..color = const Color(0xFF14221E)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    const divisions = [-48.0, -24.0, 0.0, 24.0, 48.0];
    for (final x in divisions) {
      canvas.drawLine(Offset(x, -26), Offset(x, -13), pillarPaint);
    }

    // Dynamic Glare Sweep across the Panoramic Glass Ribbon
    if (glareSweepPhase > 0.0 && glareSweepPhase < 1.0) {
      canvas.save();
      canvas.clipPath(windowPath);

      final sweepX = -84.0 + (glareSweepPhase * 168.0);
      final glarePaint = Paint()
        ..color = tokens.glassGlareColor.withValues(
          alpha: math.sin(glareSweepPhase * math.pi) * 0.85,
        )
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(sweepX, -30),
        Offset(sweepX - 16, -10),
        glarePaint,
      );
      canvas.restore();
    }
  }

  void _drawDoorAndDetails(Canvas canvas) {
    // Passenger Entry Doors Outline
    final doorPaint = Paint()
      ..color = tokens.bodyUndersideColor.withValues(alpha: 0.65)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final doorPath = Path()
      ..moveTo(26, -12)
      ..lineTo(26, 5)
      ..moveTo(38, -12)
      ..lineTo(38, 5)
      ..moveTo(32, -12)
      ..lineTo(32, 5); // Split-leaf door divider
    canvas.drawPath(doorPath, doorPaint);

    // Amber Side Marker Light
    final markerPaint = Paint()..color = const Color(0xFFFFB300);
    canvas.drawCircle(const Offset(0, 0), 1.2, markerPaint);
  }

  void _drawWheel(Canvas canvas, Offset center, double angle) {
    const outerR = 14.0;
    const rimR = 9.8;

    // Heavy-Duty Commercial Tyre
    final tyrePaint = Paint()..color = const Color(0xFF18201D);
    canvas.drawCircle(center, outerR, tyrePaint);

    // Deep-Dish Metallic Steel Rim
    final rimPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFCFD8DC), Color(0xFF78909C), Color(0xFF263238)],
      ).createShader(Rect.fromCircle(center: center, radius: rimR));
    canvas.drawCircle(center, rimR, rimPaint);

    // Rotating Lug Nut Circle Pattern
    final nutPaint = Paint()
      ..color = const Color(0xFF1E2825)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final a = angle + (i * (math.pi / 3));
      final nutPos = Offset(center.dx + math.cos(a) * 5.2,
          center.dy + math.sin(a) * 5.2);
      canvas.drawCircle(nutPos, 0.9, nutPaint);
    }

    // Heavy-Duty Axle Hub Cap
    final hubCap = Paint()..color = const Color(0xFFB0BEC5);
    canvas.drawCircle(center, 3.0, hubCap);
    canvas.drawCircle(center, 1.2, Paint()..color = Colors.white);
  }

  void _drawLights(Canvas canvas) {
    // Dual Projector Headlight Stack
    final headlampPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(74, -4, 4, 8), const Radius.circular(1.5)),
      headlampPaint,
    );

    // Vertical Stacked LED Taillights with Pulse
    final pulseAlpha = (0.6 + (taillightPulse * 0.4)).clamp(0.0, 1.0);
    _glowPaint.color = tokens.taillightGlowColor.withValues(alpha: pulseAlpha);

    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-80, -7, 4, 12), const Radius.circular(1.5)),
      _glowPaint,
    );

    final tailCorePaint = Paint()
      ..color = Colors.white.withValues(alpha: pulseAlpha);
    canvas.drawRect(const Rect.fromLTWH(-79, -5, 1.8, 8), tailCorePaint);
  }

  @override
  bool shouldRepaint(covariant BusPainter oldDelegate) {
    return oldDelegate.wheelAngle != wheelAngle ||
        oldDelegate.idleBob != idleBob ||
        oldDelegate.taillightPulse != taillightPulse ||
        oldDelegate.glareSweepPhase != glareSweepPhase ||
        oldDelegate.tokens != tokens;
  }
}

