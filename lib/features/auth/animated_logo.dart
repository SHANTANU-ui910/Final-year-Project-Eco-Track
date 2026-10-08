import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// 88px luxury squircle brand tile with vector drawing animation:
/// footprint stroke draws over 900ms (easeInOut), leaf fills over 400ms.
/// Automatically scales to 0.72 when keyboard opens.
class AnimatedLogoTile extends StatefulWidget {
  final double scaleFactor; // Keyboard avoidance factor (1.0 -> 0.72)
  final bool isDark;

  const AnimatedLogoTile({
    super.key,
    this.scaleFactor = 1.0,
    this.isDark = false,
  });

  @override
  State<AnimatedLogoTile> createState() => _AnimatedLogoTileState();
}

typedef AnimatedLogo = AnimatedLogoTile;

class _AnimatedLogoTileState extends State<AnimatedLogoTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _strokeProgress;
  late Animation<double> _leafFillProgress;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // Stroke draws over first 900ms
    _strokeProgress = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.69, curve: Curves.easeInOutCubic),
    );

    // Leaf fill blossoms over remaining 400ms
    _leafFillProgress = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.69, 1.0, curve: Curves.easeOutQuad),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tileSize = 88.0 * widget.scaleFactor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.0 * widget.scaleFactor),
        gradient: widget.isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2B22), Color(0xFF081C16)],
              )
            : EcoTokens.logoTileGradient,
        border: Border.all(
          color: widget.isDark
              ? const Color(0x33B9F36B)
              : const Color(0x80D4E6DC),
          width: 1.2,
        ),
        boxShadow: [
          // Soft ambient emerald aura
          BoxShadow(
            color: widget.isDark
                ? const Color(0x2E0F6B4A)
                : const Color(0x1F0F6B4A),
            offset: const Offset(0, 10),
            blurRadius: 24,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.35 : 0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            return CustomPaint(
              size: Size(44.0 * widget.scaleFactor, 44.0 * widget.scaleFactor),
              painter: _EcoFootprintLeafPainter(
                strokeProgress: _strokeProgress.value,
                leafFillProgress: _leafFillProgress.value,
                isDark: widget.isDark,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Precision procedural painter rendering the EcoTrack footprint and leaf icon
class _EcoFootprintLeafPainter extends CustomPainter {
  final double strokeProgress;
  final double leafFillProgress;
  final bool isDark;

  static final Paint _strokePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final Paint _fillPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;

  _EcoFootprintLeafPainter({
    required this.strokeProgress,
    required this.leafFillProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Scale unit box [0, 44] to target size
    canvas.save();
    canvas.scale(w / 44.0, h / 44.0);

    final primaryColor = isDark ? EcoTokens.limeGlow : EcoTokens.primary;
    final leafColor = isDark ? EcoTokens.bright : EcoTokens.bright;

    _strokePaint
      ..color = primaryColor
      ..strokeWidth = 2.4;

    // 1. Footprint Contour Path
    final footprintPath = Path()
      ..moveTo(22, 38)
      ..cubicTo(14, 38, 10, 32, 12, 24)
      ..cubicTo(13, 20, 17, 18, 17, 14)
      ..cubicTo(17, 10, 21, 6, 26, 6)
      ..cubicTo(32, 6, 36, 12, 34, 20)
      ..cubicTo(33, 27, 28, 38, 22, 38);

    // Extract path segment according to stroke progress
    if (strokeProgress > 0.0) {
      final metrics = footprintPath.computeMetrics().first;
      final extracted = metrics.extractPath(0.0, metrics.length * strokeProgress);
      canvas.drawPath(extracted, _strokePaint);
    }

    // 2. Toe Nodes (Staggered dots appearing with stroke)
    if (strokeProgress > 0.4) {
      _fillPaint.color = primaryColor;
      final toeAlpha = ((strokeProgress - 0.4) / 0.6).clamp(0.0, 1.0);
      _fillPaint.color = primaryColor.withValues(alpha: toeAlpha);

      const toes = [
        Offset(29, 3.5),
        Offset(23, 2.5),
        Offset(17, 4.0),
        Offset(12, 7.5),
        Offset(8, 12.0),
      ];

      for (int i = 0; i < toes.length; i++) {
        final radius = 2.2 - (i * 0.25);
        canvas.drawCircle(toes[i], radius, _fillPaint);
      }
    }

    // 3. Central Eco Leaf Fill (Blossoms in second phase)
    if (leafFillProgress > 0.0) {
      const leafCenter = Offset(23, 21);
      canvas.save();
      canvas.translate(leafCenter.dx, leafCenter.dy);
      final scale = math.sin(leafFillProgress * math.pi * 0.5);
      canvas.scale(scale, scale);

      final leafPath = Path()
        ..moveTo(0, -9)
        ..cubicTo(7, -8, 8, 2, 0, 9)
        ..cubicTo(-8, 2, -7, -8, 0, -9)
        ..close();

      // Leaf Gradient Fill
      _fillPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          leafColor,
          isDark ? EcoTokens.limeGlow : EcoTokens.primary,
        ],
      ).createShader(const Rect.fromLTWH(-8, -9, 16, 18));

      canvas.drawPath(leafPath, _fillPaint);
      _fillPaint.shader = null;

      // Leaf Central Vein
      final veinPaint = Paint()
        ..color = isDark ? EcoTokens.darkBg : Colors.white
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(0, -7), const Offset(0, 7), veinPaint);

      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EcoFootprintLeafPainter old) =>
      old.strokeProgress != strokeProgress ||
      old.leafFillProgress != leafFillProgress ||
      old.isDark != isDark;
}
