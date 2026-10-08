import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/design_tokens.dart';

/// Animated GPS telemetry chip transitioning from searching radar pulse to locked emerald checkmark
class GpsStatusChip extends StatefulWidget {
  final bool isLocked;
  final String statusText;
  final bool isDark;

  const GpsStatusChip({
    super.key,
    required this.isLocked,
    this.statusText = 'GPS Locked (±3m)',
    this.isDark = false,
  });

  @override
  State<GpsStatusChip> createState() => _GpsStatusChipState();
}

class _GpsStatusChipState extends State<GpsStatusChip> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.isLocked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.5),
      decoration: BoxDecoration(
        color: isLocked
            ? (widget.isDark ? const Color(0xFF0E2A1E) : const Color(0xFFEAF5EE))
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(EcoDesignTokens.radiusPill),
        border: Border.all(
          color: isLocked
              ? (widget.isDark ? const Color(0xFF1E5038) : const Color(0xFFC8E6C9))
              : const Color(0xFFFDE68A),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLocked)
            const PhosphorIcon(
              PhosphorIconsFill.checkCircle,
              size: 14.0,
              color: EcoDesignTokens.bright,
            )
          else
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final scale = 1.0 + (_pulseController.value * 0.75);
                final opacity = (1.0 - _pulseController.value) * 0.7;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD97706).withValues(alpha: opacity),
                        ),
                      ),
                    ),
                    Container(
                      width: 6.0,
                      height: 6.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(width: 7.0),
          Text(
            isLocked ? widget.statusText : 'Searching GPS...',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              color: isLocked
                  ? (widget.isDark ? EcoDesignTokens.limeGlow : EcoDesignTokens.deepEmerald)
                  : const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }
}
