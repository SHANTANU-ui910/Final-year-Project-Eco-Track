import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// 240-degree custom arc velocity gauge with emerald-to-lime progress glow and centered speed telemetry
class SpeedArcGauge extends StatelessWidget {
  final double currentSpeedKmh;
  final double maxSpeedKmh;
  final bool isDark;
  final bool isCompact;

  const SpeedArcGauge({
    super.key,
    required this.currentSpeedKmh,
    this.maxSpeedKmh = 140.0,
    this.isDark = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final gaugeWidth = isCompact ? 120.0 : 220.0;
    final gaugeHeight = isCompact ? 95.0 : 160.0;

    return SizedBox(
      width: gaugeWidth,
      height: gaugeHeight,
      child: CustomPaint(
        painter: _SpeedArcGaugePainter(
          currentSpeed: currentSpeedKmh.clamp(0.0, maxSpeedKmh),
          maxSpeed: maxSpeedKmh,
          isDark: isDark,
          isCompact: isCompact,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: isCompact ? 14.0 : 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Velocity Number with Tabular Figures
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currentSpeedKmh.toStringAsFixed(1),
                      style: (isCompact
                              ? EcoDesignTokens.heroSpeed(isDark: isDark).copyWith(fontSize: 26.0, height: 1.0)
                              : EcoDesignTokens.heroSpeed(isDark: isDark)),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'km/h',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isCompact ? 10.0 : 14.0,
                        fontWeight: FontWeight.w700,
                        color: isDark ? EcoDesignTokens.darkMuted : EcoDesignTokens.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1.0),
                Text(
                  isCompact ? 'LIVE SPEED' : 'LIVE GPS VELOCITY',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isCompact ? 8.0 : 10.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: isCompact ? 0.8 : 1.2,
                    color: isDark ? EcoDesignTokens.limeGlow : EcoDesignTokens.deepEmerald,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedArcGaugePainter extends CustomPainter {
  final double currentSpeed;
  final double maxSpeed;
  final bool isDark;
  final bool isCompact;

  _SpeedArcGaugePainter({
    required this.currentSpeed,
    required this.maxSpeed,
    required this.isDark,
    this.isCompact = false,
  });

  // 240-degree arc: spans from 150° (5pi/6) to 390° (13pi/6) -> total 240° (4pi/3)
  static const double startAngle = 5 * math.pi / 6;
  static const double sweepAngle = 4 * math.pi / 3;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * (isCompact ? 0.68 : 0.72));
    final radius = size.width * (isCompact ? 0.42 : 0.44);
    final strokeW = isCompact ? 6.5 : 10.0;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Background Track Arc (Mint Gray)
    final trackPaint = Paint()
      ..color = isDark ? const Color(0xFF133427) : const Color(0xFFE2EFE7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);

    // 2. Velocity Progress Ratio
    final progressRatio = (currentSpeed / maxSpeed).clamp(0.0, 1.0);
    final activeSweep = sweepAngle * progressRatio;

    if (activeSweep > 0.005) {
      // Linear/Sweep Gradient for Progress Arc
      final gradientPaint = Paint()
        ..shader = const SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: [
            EcoDesignTokens.deepEmerald,
            EcoDesignTokens.primary,
            EcoDesignTokens.bright,
            EcoDesignTokens.limeGlow,
          ],
          transform: GradientRotation(startAngle),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, activeSweep, false, gradientPaint);

      // Glowing tip bulb at current speed
      final tipAngle = startAngle + activeSweep;
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);

      final glowPaint = Paint()
        ..color = EcoDesignTokens.limeGlow.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawCircle(Offset(tipX, tipY), 5.0, glowPaint);

      final tipCenterPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(tipX, tipY), 3.0, tipCenterPaint);
    }

    // 3. Tick Marks Every 20 km/h
    final tickCount = (maxSpeed / 20.0).round();
    final tickPaint = Paint()
      ..color = isDark ? const Color(0xFF2A5040) : const Color(0xFFB5D1C3)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= tickCount; i++) {
      final t = i / tickCount;
      final angle = startAngle + (sweepAngle * t);

      final innerRadius = radius - 14.0;
      final outerRadius = radius - 8.0;

      final p1 = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );

      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedArcGaugePainter oldDelegate) =>
      oldDelegate.currentSpeed != currentSpeed ||
      oldDelegate.maxSpeed != maxSpeed ||
      oldDelegate.isDark != isDark ||
      oldDelegate.isCompact != isCompact;
}
