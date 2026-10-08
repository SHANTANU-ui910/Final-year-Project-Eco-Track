import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Trust Badge: "VERIFIED MOBILITY NODE"
/// Features:
/// - 1.8s live pulsing beacon dot (scale 1.0 -> 1.6, opacity 0.6 -> 0.0)
/// - Periodic specular shimmer sweep (every 3.5s)
/// - Adaptive light and dark styling
class VerifiedBadge extends StatefulWidget {
  final bool isDark;

  const VerifiedBadge({
    super.key,
    this.isDark = false,
  });

  @override
  State<VerifiedBadge> createState() => _VerifiedBadgeState();
}

class _VerifiedBadgeState extends State<VerifiedBadge>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    // 1.8s continuous beacon pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // 3.5s periodic shimmer sweep
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isReducedMotion = MediaQuery.of(context).disableAnimations;

    return ClipRRect(
      borderRadius: BorderRadius.circular(EcoTokens.radiusChip),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base Pill Container
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: isDark
                  ? EcoTokens.limeGlow.withValues(alpha: 0.10)
                  : EcoTokens.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(EcoTokens.radiusChip),
              border: Border.all(
                color: isDark
                    ? EcoTokens.limeGlow.withValues(alpha: 0.28)
                    : EcoTokens.primary.withValues(alpha: 0.20),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live Pulsing Beacon Dot
                SizedBox(
                  width: 14.0,
                  height: 14.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!isReducedMotion)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) {
                            final scale = 1.0 + (_pulseController.value * 0.6);
                            final opacity = (1.0 - _pulseController.value) * 0.6;
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (isDark ? EcoTokens.limeGlow : EcoTokens.bright)
                                      .withValues(alpha: opacity),
                                ),
                              ),
                            );
                          },
                        ),
                      // Core Stationary Dot
                      Container(
                        width: 6.0,
                        height: 6.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? EcoTokens.limeGlow : EcoTokens.bright,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),

                // Badge Text
                Text(
                  'VERIFIED MOBILITY NODE',
                  style: EcoTokens.trustBadge(isDark: isDark),
                ),
              ],
            ),
          ),

          // Periodic Shimmer Glint Sweep
          if (!isReducedMotion)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, _) {
                  // Shimmer runs during first 20% of cycle (700ms)
                  final val = _shimmerController.value;
                  if (val > 0.22) return const SizedBox.shrink();

                  final p = val / 0.22;
                  return FractionallySizedBox(
                    widthFactor: 0.4,
                    alignment: Alignment(lerpDouble(-2.5, 2.5, p)!, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: isDark ? 0.25 : 0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  double? lerpDouble(num? a, num? b, double t) {
    if (a == null || b == null) return null;
    return a + (b - a) * t;
  }
}

