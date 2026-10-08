import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/design_tokens.dart';

/// 3 separate glassmorphism telemetry tiles for Trip Distance, Emissions, and Duration
class StatsTiles extends StatefulWidget {
  final double distanceKm;
  final double emissionsKg;
  final int durationSeconds;
  final bool isRunning;
  final bool isDark;

  const StatsTiles({
    super.key,
    required this.distanceKm,
    required this.emissionsKg,
    required this.durationSeconds,
    this.isRunning = false,
    this.isDark = false,
  });

  @override
  State<StatsTiles> createState() => _StatsTilesState();
}

class _StatsTilesState extends State<StatsTiles> with SingleTickerProviderStateMixin {
  late final AnimationController _colonBlinkController;

  @override
  void initState() {
    super.initState();
    // 1-second blinking colon loop (500ms visible, 500ms invisible)
    _colonBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isRunning) {
      _colonBlinkController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant StatsTiles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning && !_colonBlinkController.isAnimating) {
      _colonBlinkController.repeat();
    } else if (!widget.isRunning && _colonBlinkController.isAnimating) {
      _colonBlinkController.stop();
      _colonBlinkController.reset();
    }
  }

  @override
  void dispose() {
    _colonBlinkController.dispose();
    super.dispose();
  }

  String _formatMinutes(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    return m.toString().padLeft(2, '0');
  }

  String _formatSeconds(int totalSeconds) {
    final s = totalSeconds % 60;
    return s.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    final emissionColor = EcoDesignTokens.getEmissionColor(widget.emissionsKg);

    return Row(
      children: [
        // ================= TILE 1: CURRENT TRIP =================
        Expanded(
          child: _buildGlassTile(
            icon: PhosphorIconsRegular.path,
            iconColor: EcoDesignTokens.primary,
            label: 'CURRENT TRIP',
            valueWidget: Text(
              widget.distanceKm.toStringAsFixed(2),
              style: EcoDesignTokens.statNumber(isDark: widget.isDark),
            ),
            unit: 'km',
          ),
        ),
        const SizedBox(width: 10),

        // ================= TILE 2: EMISSIONS (Dynamic Semantic Tint) =================
        Expanded(
          child: _buildGlassTile(
            icon: PhosphorIconsRegular.leaf,
            iconColor: emissionColor,
            label: 'EMISSIONS',
            valueWidget: Text(
              widget.emissionsKg.toStringAsFixed(2),
              style: EcoDesignTokens.statNumber(isDark: widget.isDark).copyWith(
                color: emissionColor,
              ),
            ),
            unit: 'kg CO₂e',
            customBorderColor: emissionColor.withValues(alpha: 0.25),
          ),
        ),
        const SizedBox(width: 10),

        // ================= TILE 3: DURATION (1s Blinking Colon) =================
        Expanded(
          child: _buildGlassTile(
            icon: PhosphorIconsRegular.clock,
            iconColor: EcoDesignTokens.bright,
            label: 'DURATION',
            valueWidget: AnimatedBuilder(
              animation: _colonBlinkController,
              builder: (context, _) {
                final showColon = !widget.isRunning || _colonBlinkController.value < 0.5;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatMinutes(widget.durationSeconds),
                      style: EcoDesignTokens.statNumber(isDark: widget.isDark),
                    ),
                    Opacity(
                      opacity: showColon ? 1.0 : 0.0,
                      child: Text(
                        ':',
                        style: EcoDesignTokens.statNumber(isDark: widget.isDark),
                      ),
                    ),
                    Text(
                      _formatSeconds(widget.durationSeconds),
                      style: EcoDesignTokens.statNumber(isDark: widget.isDark),
                    ),
                  ],
                );
              },
            ),
            unit: 'min:sec',
          ),
        ),
      ],
    );
  }

  Widget _buildGlassTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget valueWidget,
    required String unit,
    Color? customBorderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: widget.isDark ? EcoDesignTokens.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(EcoDesignTokens.radiusTile),
        border: Border.all(
          color: customBorderColor ?? (widget.isDark ? EcoDesignTokens.darkBorder : EcoDesignTokens.border),
          width: 1.0,
        ),
        boxShadow: EcoDesignTokens.cardElevation,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon & Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: widget.isDark ? EcoDesignTokens.darkMuted : EcoDesignTokens.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),

          // Tabular Value Display
          FittedBox(
            fit: BoxFit.scaleDown,
            child: valueWidget,
          ),
          const SizedBox(height: 2.0),

          // Unit Label (Strictly line 2, never wraps)
          Text(
            unit,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? EcoDesignTokens.darkMuted : EcoDesignTokens.muted,
            ),
          ),
        ],
      ),
    );
  }
}

