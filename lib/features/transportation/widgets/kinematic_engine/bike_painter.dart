import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Renders the high-performance sport motorcycle with sculpted fuel tank,
/// exposed chassis frame, chrome exhaust system, tucked-in rider, and dynamic lighting.
class BikePainter extends CustomPainter {
  final ModuleThemeTokens tokens;
  final double wheelAngle;
  final double idleBob;
  final double taillightPulse; // 0.0 -> 1.0
  final double glareSweepPhase; // 0.0 -> 1.0 across glare window

  static final Paint _paint = Paint()..isAntiAlias = true;
  static final Paint _glowPaint = Paint()
    ..isAntiAlias = true
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
  static final Paint _headlightBeamPaint = Paint()
    ..isAntiAlias = true
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.0);

  BikePainter({
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

    // 1. Forward Headlight Projection Beam
    _drawHeadlightBeam(canvas);

    // 2. Rider Silhouette in Sport Tucked Stance
    _drawSportRider(canvas);

    // 3. Exposed Mechanical Frame, Engine Block & Chrome Exhaust
    _drawEngineAndExhaust(canvas);

    // 4. Sculpted Fuel Tank & Tail Fairing
    _drawBodywork(canvas);

    // 5. Aerodynamic Flyscreen with Glare Sweep
    _drawFlyscreen(canvas);

    // 6. Dual Alloy Wheels (Rear & Front)
    _drawWheel(canvas, const Offset(-42, 11), wheelAngle);
    _drawWheel(canvas, const Offset(42, 11), wheelAngle);

    // 7. Sharp Angular LED Headlight & Tail Indicator
    _drawLights(canvas);

    canvas.restore();
  }

  void _drawHeadlightBeam(Canvas canvas) {
    final beamPath = Path()
      ..moveTo(52, -7)
      ..lineTo(135, 6)
      ..lineTo(125, 22)
      ..lineTo(50, 1)
      ..close();

    _headlightBeamPaint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        tokens.headlightBeamColor,
        tokens.headlightBeamColor.withValues(alpha: 0.0),
      ],
    ).createShader(const Rect.fromLTWH(50, -7, 85, 29));

    canvas.drawPath(beamPath, _headlightBeamPaint);
  }

  void _drawSportRider(Canvas canvas) {
    final riderPaint = Paint()
      ..color = tokens.bodyUndersideColor.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;

    // Aggressive forward lean torso
    final torsoPath = Path()
      ..moveTo(-18, -10) // Hip on seat
      ..lineTo(-3, -32) // Forward-leaning back
      ..lineTo(14, -28) // Chest
      ..lineTo(4, -6)
      ..close();
    canvas.drawPath(torsoPath, riderPaint);

    // Full-Face Aerodynamic Helmet
    canvas.drawOval(
      const Rect.fromLTWH(3, -48, 20, 19),
      riderPaint,
    );

    // Smoked Visor Curve
    final visorPaint = Paint()
      ..color = tokens.secondaryAccent.withValues(alpha: 0.75)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      const Rect.fromLTWH(11, -45, 12, 12),
      -0.6,
      1.2,
      false,
      visorPaint,
    );

    // Arm leaning into clip-on handlebar
    final armPath = Path()
      ..moveTo(10, -26)
      ..lineTo(26, -17)
      ..lineTo(32, -14);
    final armPaint = Paint()
      ..color = tokens.bodyUndersideColor.withValues(alpha: 0.92)
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(armPath, armPaint);

    // Tucked leg on rearset footpeg
    final legPath = Path()
      ..moveTo(-14, -8)
      ..lineTo(-2, 2)
      ..lineTo(-12, 6);
    final legPaint = Paint()
      ..color = tokens.bodyUndersideColor.withValues(alpha: 0.88)
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(legPath, legPaint);
  }

  void _drawEngineAndExhaust(Canvas canvas) {
    // 1. Engine Cylinder Block & Crankcase
    final enginePaint = Paint()..color = const Color(0xFF263238);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, -2, 22, 11),
        const Radius.circular(3),
      ),
      enginePaint,
    );

    // Engine cooling fins
    final finPaint = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(Offset(-4, 0.0 + i * 3.0), Offset(14, 0.0 + i * 3.0), finPaint);
    }

    // 2. High-Polish Chrome Exhaust System
    final exhaustPath = Path()
      ..moveTo(12, 5)
      ..quadraticBezierTo(2, 11, -14, 11)
      ..lineTo(-38, 5); // Swept-up megaphone silencer

    final exhaustPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), Color(0xFFCFD8DC), Color(0xFF78909C)],
      ).createShader(const Rect.fromLTWH(-38, 4, 52, 8))
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(exhaustPath, exhaustPaint);

    // 3. Telescopic Inverted Front Forks
    final forkPaint = Paint()
      ..color = const Color(0xFFFFC107) // Gold anodized inverted forks
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(32, -14), const Offset(42, 11), forkPaint);
  }

  void _drawBodywork(Canvas canvas) {
    const bodyRect = Rect.fromLTWH(-48, -26, 96, 36);

    // 1. Muscular Fuel Tank & Sharp Tail Section
    final bodyPath = Path()
      ..moveTo(-46, -3) // Sharp tail tip
      ..lineTo(-26, -11)
      ..lineTo(-12, -10) // Saddle scoop
      ..cubicTo(0, -24, 18, -24, 28, -15) // Muscular fuel tank hump
      ..lineTo(36, -15)
      ..quadraticBezierTo(38, -6, 26, -2)
      ..lineTo(-16, -2)
      ..lineTo(-38, 2)
      ..close();

    _paint.shader = tokens.bodyGradient.createShader(bodyRect);
    canvas.drawPath(bodyPath, _paint);

    // 2. Tank Shoulder Crease & Specular Highlight
    final tankHighlight = Path()
      ..moveTo(2, -19)
      ..cubicTo(12, -23, 22, -20, 26, -16);
    final highlightPaint = Paint()
      ..color = tokens.bodyHighlightColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(tankHighlight, highlightPaint);
  }

  void _drawFlyscreen(Canvas canvas) {
    const screenRect = Rect.fromLTWH(32, -26, 12, 12);
    final screenPath = Path()
      ..moveTo(32, -14)
      ..lineTo(36, -25)
      ..lineTo(44, -22)
      ..lineTo(40, -12)
      ..close();

    _paint.shader = tokens.glassGradient.createShader(screenRect);
    canvas.drawPath(screenPath, _paint);

    if (glareSweepPhase > 0.0 && glareSweepPhase < 1.0) {
      canvas.save();
      canvas.clipPath(screenPath);

      final sweepX = 28.0 + (glareSweepPhase * 24.0);
      final glarePaint = Paint()
        ..color = tokens.glassGlareColor.withValues(
          alpha: math.sin(glareSweepPhase * math.pi) * 0.8,
        )
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(sweepX, -28),
        Offset(sweepX - 8, -10),
        glarePaint,
      );
      canvas.restore();
    }
  }

  void _drawWheel(Canvas canvas, Offset center, double angle) {
    const outerR = 13.5;
    const rimR = 9.5;

    // Dark Sport Tyre with Low Profile
    final tyrePaint = Paint()..color = const Color(0xFF1B2320);
    canvas.drawCircle(center, outerR, tyrePaint);

    // Lightweight Machined Rim
    final rimPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFECEFF1), Color(0xFF78909C), Color(0xFF263238)],
      ).createShader(Rect.fromCircle(center: center, radius: rimR));
    canvas.drawCircle(center, rimR, rimPaint);

    // Directional Y-Spoke Sport Wheels
    final spokePaint = Paint()
      ..color = const Color(0xFF1E2825)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final a = angle + (i * (2 * math.pi / 3));
      final spokeEnd = Offset(center.dx + math.cos(a) * (rimR - 1.2),
          center.dy + math.sin(a) * (rimR - 1.2));
      canvas.drawLine(center, spokeEnd, spokePaint);

      // Y-split branches
      final branch1 = Offset(
        center.dx + math.cos(a + 0.3) * (rimR - 1.2),
        center.dy + math.sin(a + 0.3) * (rimR - 1.2),
      );
      canvas.drawLine(
        Offset(center.dx + math.cos(a) * 4.5, center.dy + math.sin(a) * 4.5),
        branch1,
        spokePaint,
      );
    }

    // Ventilated Disc Brake Rotor
    final discPaint = Paint()
      ..color = const Color(0x77B0BEC5)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 5.5, discPaint);

    // Center Hub Cap
    final centerCap = Paint()..color = Colors.white;
    canvas.drawCircle(center, 2.0, centerCap);
  }

  void _drawLights(Canvas canvas) {
    // Angular Headlight Unit
    final headlampPaint = Paint()..color = Colors.white;
    canvas.drawPath(
      Path()
        ..moveTo(42, -9)
        ..lineTo(48, -4)
        ..lineTo(44, 0)
        ..close(),
      headlampPaint,
    );

    // Sharp LED Tail Light with Pulse
    final pulseAlpha = (0.6 + (taillightPulse * 0.4)).clamp(0.0, 1.0);
    _glowPaint.color = tokens.taillightGlowColor.withValues(alpha: pulseAlpha);

    canvas.drawOval(
      const Rect.fromLTWH(-48, -5, 7, 7),
      _glowPaint,
    );

    final tailCorePaint = Paint()
      ..color = Colors.white.withValues(alpha: pulseAlpha);
    canvas.drawCircle(const Offset(-45, -2), 1.6, tailCorePaint);
  }

  @override
  bool shouldRepaint(covariant BikePainter oldDelegate) {
    return oldDelegate.wheelAngle != wheelAngle ||
        oldDelegate.idleBob != idleBob ||
        oldDelegate.taillightPulse != taillightPulse ||
        oldDelegate.glareSweepPhase != glareSweepPhase ||
        oldDelegate.tokens != tokens;
  }
}

