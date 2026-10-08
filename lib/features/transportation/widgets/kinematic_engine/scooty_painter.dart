import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Renders the luxury Scooty with ergonomic step-through chassis, front leg shield,
/// fluidly waving scarf rider silhouette, alloy star wheels, and lighting optics.
class ScootyPainter extends CustomPainter {
  final ModuleThemeTokens tokens;
  final double wheelAngle;
  final double idleBob;
  final double taillightPulse; // 0.0 -> 1.0
  final double glareSweepPhase; // 0.0 -> 1.0 across glare window

  // Reusable cached paints
  static final Paint _paint = Paint()..isAntiAlias = true;
  static final Paint _glowPaint = Paint()
    ..isAntiAlias = true
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
  static final Paint _headlightBeamPaint = Paint()
    ..isAntiAlias = true
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

  ScootyPainter({
    required this.tokens,
    required this.wheelAngle,
    required this.idleBob,
    required this.taillightPulse,
    required this.glareSweepPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // Center vehicle horizontally, position above road with idle float
    final cx = size.width * 0.48;
    final cy = size.height * 0.68 + idleBob;
    canvas.translate(cx, cy);

    // 1. Headlight Forward Light Cone on Road
    _drawHeadlightBeam(canvas);

    // 2. Rider Silhouette with Billowing Scarf
    _drawRiderWithScarf(canvas);

    // 3. Scooty Step-Through Chassis & Leg Shield
    _drawChassisBody(canvas);

    // 4. Compact Windscreen with Diagonal Glare Sweep
    _drawWindscreen(canvas);

    // 5. Precision Wheels (Rear and Front)
    _drawWheel(canvas, const Offset(-36, 12), wheelAngle);
    _drawWheel(canvas, const Offset(36, 12), wheelAngle);

    // 6. Optic Lights (Headlamp & Pulsing LED Taillight)
    _drawLights(canvas);

    canvas.restore();
  }

  void _drawHeadlightBeam(Canvas canvas) {
    final beamPath = Path()
      ..moveTo(48, -12)
      ..lineTo(130, 2)
      ..lineTo(120, 18)
      ..lineTo(46, -4)
      ..close();

    _headlightBeamPaint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        tokens.headlightBeamColor,
        tokens.headlightBeamColor.withValues(alpha: 0.0),
      ],
    ).createShader(const Rect.fromLTWH(46, -12, 84, 30));

    canvas.drawPath(beamPath, _headlightBeamPaint);
  }

  void _drawRiderWithScarf(Canvas canvas) {
    final riderPaint = Paint()
      ..color = tokens.bodyUndersideColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    // Torso / Upright posture
    final bodyPath = Path()
      ..moveTo(-12, -4)
      ..lineTo(-6, -34)
      ..lineTo(4, -33)
      ..lineTo(6, -6)
      ..close();
    canvas.drawPath(bodyPath, riderPaint);

    // Aerodynamic Helmet
    canvas.drawOval(
      const Rect.fromLTWH(-9, -50, 19, 18),
      riderPaint,
    );

    // Glossy Visor Highlight
    final visorPaint = Paint()
      ..color = tokens.secondaryAccent.withValues(alpha: 0.65)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      const Rect.fromLTWH(-2, -47, 12, 12),
      -0.5,
      1.1,
      false,
      visorPaint,
    );

    // Arm reaching to handlebar
    final armPath = Path()
      ..moveTo(1, -27)
      ..quadraticBezierTo(18, -23, 24, -18);
    final armPaint = Paint()
      ..color = tokens.bodyUndersideColor.withValues(alpha: 0.9)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(armPath, armPaint);

    // Fluid Billowing Scarf (Animated with dynamic wave)
    final scarfWave = math.sin(wheelAngle * 2.0) * 4.0;
    final scarfPath = Path()
      ..moveTo(-7, -35)
      ..cubicTo(-22, -37 + scarfWave, -36, -30 - scarfWave, -50, -34 + scarfWave)
      ..lineTo(-51, -29 + scarfWave)
      ..cubicTo(-36, -26 - scarfWave, -22, -32 + scarfWave, -7, -31)
      ..close();

    final scarfPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          tokens.primaryAccent,
          tokens.secondaryAccent.withValues(alpha: 0.4),
        ],
      ).createShader(const Rect.fromLTWH(-52, -40, 50, 16));
    canvas.drawPath(scarfPath, scarfPaint);
  }

  void _drawChassisBody(Canvas canvas) {
    const bodyRect = Rect.fromLTWH(-48, -26, 96, 40);

    // 1. Sleek Step-Through Body Form
    final bodyPath = Path()
      ..moveTo(-46, 6)
      ..quadraticBezierTo(-48, -14, -28, -17) // Rear cowl
      ..lineTo(-8, -17)
      ..quadraticBezierTo(-4, 0, 4, 3) // Floorboard drop
      ..lineTo(16, 3)
      ..quadraticBezierTo(26, -6, 36, -24) // Front Apron sweep
      ..quadraticBezierTo(44, -22, 48, -14) // Headlamp cowl
      ..lineTo(42, 6) // Front fork anchor
      ..quadraticBezierTo(32, 10, 24, 6)
      ..lineTo(8, 6)
      ..lineTo(-40, 6)
      ..close();

    _paint.shader = tokens.bodyGradient.createShader(bodyRect);
    canvas.drawPath(bodyPath, _paint);

    // 2. High-Gloss Shoulder Highlight Streak
    final highlightPath = Path()
      ..moveTo(-34, -14)
      ..lineTo(-10, -14)
      ..moveTo(22, -2)
      ..quadraticBezierTo(28, -10, 36, -20);

    final highlightPaint = Paint()
      ..color = tokens.bodyHighlightColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(highlightPath, highlightPaint);

    // 3. Ergonomic Seat Cushion
    final seatPath = Path()
      ..moveTo(-38, -17)
      ..quadraticBezierTo(-22, -22, -6, -17)
      ..lineTo(-6, -14)
      ..lineTo(-38, -14)
      ..close();
    final seatPaint = Paint()..color = const Color(0xFF1B2A26);
    canvas.drawPath(seatPath, seatPaint);
  }

  void _drawWindscreen(Canvas canvas) {
    const screenRect = Rect.fromLTWH(30, -38, 16, 18);
    final screenPath = Path()
      ..moveTo(34, -20)
      ..lineTo(38, -36)
      ..quadraticBezierTo(44, -38, 47, -34)
      ..lineTo(44, -18)
      ..close();

    _paint.shader = tokens.glassGradient.createShader(screenRect);
    canvas.drawPath(screenPath, _paint);

    // Glare Sweep across Windscreen
    if (glareSweepPhase > 0.0 && glareSweepPhase < 1.0) {
      canvas.save();
      canvas.clipPath(screenPath);

      final sweepX = 26.0 + (glareSweepPhase * 28.0);
      final glarePaint = Paint()
        ..color = tokens.glassGlareColor.withValues(
          alpha: math.sin(glareSweepPhase * math.pi) * 0.7,
        )
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(sweepX, -40),
        Offset(sweepX - 6, -16),
        glarePaint,
      );
      canvas.restore();
    }
  }

  void _drawWheel(Canvas canvas, Offset center, double angle) {
    const outerR = 12.0;
    const rimR = 8.5;

    // Dark Rubber Tyre
    final tyrePaint = Paint()..color = const Color(0xFF1E2825);
    canvas.drawCircle(center, outerR, tyrePaint);

    // Metallic Machined Rim
    final rimPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFECEFF1), Color(0xFF90A4AE), Color(0xFF455A64)],
      ).createShader(Rect.fromCircle(center: center, radius: rimR));
    canvas.drawCircle(center, rimR, rimPaint);

    // Rotating 5-Spoke Star Pattern
    final spokePaint = Paint()
      ..color = const Color(0xFF263238)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      final a = angle + (i * (2 * math.pi / 5));
      final p2 = Offset(center.dx + math.cos(a) * (rimR - 1.2),
          center.dy + math.sin(a) * (rimR - 1.2));
      canvas.drawLine(center, p2, spokePaint);
    }

    // Center Chrome Cap Highlight
    final capPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 2.0, capPaint);
  }

  void _drawLights(Canvas canvas) {
    // Front Projector Headlamp Crystal
    final headlampPaint = Paint()..color = Colors.white;
    canvas.drawOval(const Rect.fromLTWH(44, -14, 4, 7), headlampPaint);

    // Rear Pulsing LED Taillight
    final pulseAlpha = (0.55 + (taillightPulse * 0.45)).clamp(0.0, 1.0);
    _glowPaint.color = tokens.taillightGlowColor.withValues(alpha: pulseAlpha);

    canvas.drawOval(
      const Rect.fromLTWH(-48, -13, 8, 8),
      _glowPaint,
    );

    final tailCorePaint = Paint()
      ..color = Colors.white.withValues(alpha: pulseAlpha);
    canvas.drawCircle(const Offset(-46, -9), 1.8, tailCorePaint);
  }

  @override
  bool shouldRepaint(covariant ScootyPainter oldDelegate) {
    return oldDelegate.wheelAngle != wheelAngle ||
        oldDelegate.idleBob != idleBob ||
        oldDelegate.taillightPulse != taillightPulse ||
        oldDelegate.glareSweepPhase != glareSweepPhase ||
        oldDelegate.tokens != tokens;
  }
}

