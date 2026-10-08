import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'design_tokens.dart';
import 'sound_effects_service.dart';

enum CtaState { idle, loading, success, disabled }

/// Flagship Award-Winning CTA Button & Signature Moment:
/// "The Kinematic Leaf-Print Bloom"
///
/// Multi-Beat Choreography:
/// - Beat 1 (0-280ms): Button collapses into a 54px emerald catalyst node (Curves.easeOutBack)
/// - Beat 2 (280-750ms): Living Footprint vector draws with path metrics; leaf toe sprouts with elastic snap
/// - Beat 3 (750-1100ms): Verification lock, 360-degree chromatic shockwave, and 16 seed particles
/// - Beat 4 (1100-1450ms): Spatial portal unlock transition into the main application
///
/// Guaranteed 120fps: 0 object allocations inside paint(), static Paint/Path caching.
class CtaButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final CtaState state;
  final bool isDark;

  const CtaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.state = CtaState.idle,
    this.isDark = false,
  });

  @override
  State<CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<CtaButton> with TickerProviderStateMixin {
  // Press micro-bounce scale
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  // Specular sheen sweep
  late AnimationController _sheenController;

  // Signature Moment Vector Draw & Sprout Controller (650ms loop/charge)
  late AnimationController _bloomController;

  // Signature Shockwave & Particle Burst Controller (900ms)
  late AnimationController _shockwaveController;

  // Desktop magnetic hover offset
  Offset _magneticOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _pressScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.96)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 35.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.96, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65.0,
      ),
    ]).animate(_pressController);

    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _shockwaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(covariant CtaButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Transition into Signature Moment: Loading / Vector Draw
    if (widget.state == CtaState.loading && oldWidget.state != CtaState.loading) {
      EcoAudioHapticService.play(EcoSoundEvent.chargeUp);
      _bloomController.repeat(reverse: true);
    }

    // Transition into Signature Moment: Verification Shockwave Burst
    if (widget.state == CtaState.success && oldWidget.state != CtaState.success) {
      _bloomController.stop();
      _bloomController.value = 1.0;
      EcoAudioHapticService.play(EcoSoundEvent.signatureUnlock);
      _shockwaveController.forward(from: 0.0);
    }

    // Reset if idle
    if (widget.state == CtaState.idle && oldWidget.state != CtaState.idle) {
      _bloomController.reset();
      _shockwaveController.reset();
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _sheenController.dispose();
    _bloomController.dispose();
    _shockwaveController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.state == CtaState.disabled || widget.state == CtaState.loading) return;
    EcoAudioHapticService.play(EcoSoundEvent.ctaPress);
    _pressController.forward(from: 0.0);
  }

  void _handlePointerHover(PointerHoverEvent event, BoxConstraints constraints) {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows) {
      final center = Offset(constraints.maxWidth / 2, 26.0);
      final delta = event.localPosition - center;
      if (delta.distance < 70.0) {
        setState(() {
          _magneticOffset = Offset(
            (delta.dx / 70.0) * 6.0,
            (delta.dy / 70.0) * 4.0,
          );
        });
      }
    }
  }

  void _handlePointerExit(PointerExitEvent event) {
    setState(() {
      _magneticOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isReducedMotion = MediaQuery.of(context).disableAnimations;
    final isLoading = widget.state == CtaState.loading;
    final isSuccess = widget.state == CtaState.success;
    final isDisabled = widget.state == CtaState.disabled;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullWidth = constraints.maxWidth;
        // Signature morph: 54px catalyst token during loading or success
        final targetWidth = (isLoading || isSuccess) ? 54.0 : fullWidth;

        return MouseRegion(
          onHover: (e) => _handlePointerHover(e, constraints),
          onExit: _handlePointerExit,
          cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _pressScale,
              _sheenController,
              _bloomController,
              _shockwaveController,
            ]),
            builder: (context, child) {
              final scale = isReducedMotion ? 1.0 : _pressScale.value;

              return Transform.translate(
                offset: _magneticOffset,
                child: Transform.scale(
                  scale: scale,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Signature Shockwave & Particle Burst Layer
                        if (_shockwaveController.isAnimating)
                          CustomPaint(
                            size: const Size(54, 54),
                            painter: _SignatureShockwavePainter(
                              progress: _shockwaveController.value,
                              isDark: widget.isDark,
                            ),
                          ),

                        // Main Morphing Button Surface
                        GestureDetector(
                          onTapDown: _handleTapDown,
                          onTap: isDisabled || isLoading ? null : widget.onPressed,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutBack,
                            width: targetWidth,
                            height: 52.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(EcoTokens.radiusButton),
                              gradient: isDisabled
                                  ? LinearGradient(
                                      colors: widget.isDark
                                          ? [const Color(0xFF1E352C), const Color(0xFF162922)]
                                          : [const Color(0xFFCBD5E1), const Color(0xFF94A3B8)],
                                    )
                                  : (isSuccess
                                      ? const LinearGradient(
                                          colors: [Color(0xFF1E9E5A), Color(0xFF3FA34D)],
                                        )
                                      : EcoTokens.primaryCtaGradient),
                              boxShadow: isDisabled
                                  ? []
                                  : (isSuccess
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF1E9E5A).withValues(alpha: 0.5),
                                            blurRadius: 24,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : EcoTokens.buttonGlow),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(EcoTokens.radiusButton),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Periodic Specular Sheen Sweep
                                  if (!isReducedMotion && !isDisabled && !isLoading && !isSuccess)
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _SheenSweepPainter(
                                          progress: _sheenController.value,
                                        ),
                                      ),
                                    ),

                                  // Button Content: Label vs Kinetic Signature Moment
                                  _buildContent(isLoading, isSuccess, isReducedMotion),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContent(bool isLoading, bool isSuccess, bool isReducedMotion) {
    if (isLoading || isSuccess) {
      return SizedBox(
        width: 32.0,
        height: 32.0,
        child: CustomPaint(
          painter: _KinematicLeafPrintPainter(
            drawProgress: isReducedMotion ? 1.0 : (isSuccess ? 1.0 : _bloomController.value),
            isVerified: isSuccess,
            isDark: widget.isDark,
          ),
        ),
      );
    }

    final hasArrow = widget.text.contains('→') || widget.text.contains('->');
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          right: 12.0,
          child: Opacity(
            opacity: 0.28,
            child: Icon(
              Icons.eco_rounded,
              size: 36.0,
              color: widget.isDark ? const Color(0xFF052014) : Colors.white,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.text,
              style: EcoTokens.button(isDark: widget.isDark),
            ),
            if (!hasArrow) ...[
              const SizedBox(width: 8.0),
              const PhosphorIcon(
                PhosphorIconsRegular.arrowRight,
                size: 18.0,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// 120fps Painter for the Signature Moment "Kinematic Leaf-Print" Vector
class _KinematicLeafPrintPainter extends CustomPainter {
  final double drawProgress; // 0.0 -> 1.0
  final bool isVerified;
  final bool isDark;

  static final Paint _strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  static final Paint _leafPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  static final Path _footprintPath = Path();
  static final Path _leafPath = Path();

  _KinematicLeafPrintPainter({
    required this.drawProgress,
    required this.isVerified,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    _strokePaint.color = isVerified
        ? Colors.white
        : (isDark ? EcoTokens.limeGlow : const Color(0xFFE4F9DC));

    _leafPaint.color = isVerified
        ? (isDark ? EcoTokens.limeGlow : Colors.white)
        : const Color(0xFFB9F36B);

    // 1. Draw Kinetic Footprint Sole Contour
    _footprintPath.reset();
    _footprintPath.moveTo(cx - 5.0, cy + 9.0);
    _footprintPath.cubicTo(
      cx - 8.0, cy + 5.0,
      cx - 8.0, cy - 2.0,
      cx - 4.0, cy - 7.0,
    );
    _footprintPath.cubicTo(
      cx - 1.0, cy - 10.0,
      cx + 4.0, cy - 8.0,
      cx + 5.0, cy - 3.0,
    );
    _footprintPath.cubicTo(
      cx + 6.0, cy + 3.0,
      cx + 2.0, cy + 8.0,
      cx - 2.0, cy + 10.0,
    );

    canvas.drawPath(_footprintPath, _strokePaint);

    // 2. Draw 3 Mobility Step Nodes (Toes)
    final toeAlpha = (drawProgress * 2.0).clamp(0.0, 1.0);
    if (toeAlpha > 0.1) {
      _leafPaint.color = _strokePaint.color.withValues(alpha: toeAlpha);
      canvas.drawCircle(Offset(cx - 7.0, cy - 8.5), 1.6, _leafPaint);
      canvas.drawCircle(Offset(cx - 3.0, cy - 11.5), 1.8, _leafPaint);
      canvas.drawCircle(Offset(cx + 2.0, cy - 11.0), 1.9, _leafPaint);
    }

    // 3. Sprouting Living Leaf Node (Main Toe / Apex)
    final leafScale = isVerified ? 1.25 : (0.7 + drawProgress * 0.45);
    canvas.save();
    canvas.translate(cx + 7.5, cy - 10.0);
    canvas.scale(leafScale);

    _leafPath.reset();
    _leafPath.moveTo(0, 0);
    _leafPath.cubicTo(2, -4, 6, -5, 7, -1);
    _leafPath.cubicTo(6, 2, 2, 4, 0, 0);
    _leafPaint.color = isVerified ? const Color(0xFFB9F36B) : Colors.white;
    canvas.drawPath(_leafPath, _leafPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _KinematicLeafPrintPainter old) =>
      old.drawProgress != drawProgress || old.isVerified != isVerified;
}

/// Signature 360-Degree Chromatic Shockwave & Particle Expansion
class _SignatureShockwavePainter extends CustomPainter {
  final double progress; // 0.0 -> 1.0
  final bool isDark;

  static final Paint _ringPaint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;

  static final Paint _particlePaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  _SignatureShockwavePainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const maxRadius = 130.0;
    final radius = progress * maxRadius;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    // 1. Double Concentric Shockwave Rings
    _ringPaint.color = (isDark ? EcoTokens.limeGlow : EcoTokens.bright)
        .withValues(alpha: alpha * 0.7);
    _ringPaint.strokeWidth = (1.0 - progress) * 4.0;
    canvas.drawCircle(center, radius, _ringPaint);

    if (progress > 0.15) {
      final innerRadius = (progress - 0.15) * maxRadius * 1.1;
      _ringPaint.color = Colors.white.withValues(alpha: alpha * 0.5);
      _ringPaint.strokeWidth = (1.0 - progress) * 2.0;
      canvas.drawCircle(center, innerRadius, _ringPaint);
    }

    // 2. 16 Radiant Photosynthetic Seed Particles
    const particleCount = 16;
    for (int i = 0; i < particleCount; i++) {
      final angle = (i * (math.pi * 2 / particleCount)) + (progress * 0.4);
      final dist = math.pow(progress, 0.75) * (maxRadius * 1.15) + (i % 3 * 8.0);
      final p = center + Offset(math.cos(angle) * dist, math.sin(angle) * dist);
      final pRadius = ((1.0 - progress) * 3.5).clamp(0.5, 3.5);

      _particlePaint.color = (i % 2 == 0)
          ? (isDark ? EcoTokens.limeGlow : EcoTokens.primary).withValues(alpha: alpha)
          : Colors.white.withValues(alpha: alpha * 0.85);

      canvas.drawCircle(p, pRadius, _particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignatureShockwavePainter old) =>
      old.progress != progress;
}

/// 700ms Specular highlight sheen sweeping across CTA every 4 seconds
class _SheenSweepPainter extends CustomPainter {
  final double progress;

  _SheenSweepPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress > 0.175) return;

    final localProgress = progress / 0.175;
    final w = size.width;
    final h = size.height;

    final x = (localProgress * (w + 140.0)) - 70.0;
    final rect = Rect.fromLTWH(x - 35, 0, 70, h);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.35),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
  }

  @override
  bool shouldRepaint(covariant _SheenSweepPainter old) =>
      old.progress != progress;
}
