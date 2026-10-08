import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/design_tokens.dart';

/// 64dp floating glass bottom dock with safe-area padding for primary trip control actions
class BottomDock extends StatelessWidget {
  final bool isTracking;
  final bool isPaused;
  final VoidCallback onStartOrResume;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final bool isDark;

  const BottomDock({
    super.key,
    required this.isTracking,
    this.isPaused = false,
    required this.onStartOrResume,
    required this.onPause,
    required this.onStop,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          padding: EdgeInsets.only(
            left: 18.0,
            right: 18.0,
            top: 10.0,
            bottom: bottomPadding > 0 ? bottomPadding : 12.0,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? EcoDesignTokens.darkBg.withValues(alpha: 0.82)
                : Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: isDark ? EcoDesignTokens.darkBorder : EcoDesignTokens.border,
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF073B2E).withValues(alpha: 0.08),
                offset: const Offset(0, -6),
                blurRadius: 20,
              ),
            ],
          ),
          child: SizedBox(
            height: 52.0,
            child: isTracking
                ? Row(
                    children: [
                      // Pause / Resume Toggle
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? EcoDesignTokens.darkInk : EcoDesignTokens.deepEmerald,
                            side: BorderSide(
                              color: isDark ? EcoDesignTokens.darkBorder : EcoDesignTokens.border,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(EcoDesignTokens.radiusButton),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            isPaused ? onStartOrResume() : onPause();
                          },
                          icon: PhosphorIcon(
                            isPaused ? PhosphorIconsFill.play : PhosphorIconsFill.pause,
                            size: 18,
                          ),
                          label: Text(
                            isPaused ? 'Resume' : 'Pause',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),

                      // Finish Trip Primary Action Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EcoDesignTokens.deepEmerald,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(EcoDesignTokens.radiusButton),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            onStop();
                          },
                          icon: const PhosphorIcon(
                            PhosphorIconsFill.stop,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Finish Trip',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EcoDesignTokens.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(EcoDesignTokens.radiusButton),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                      ),
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        onStartOrResume();
                      },
                      icon: const PhosphorIcon(
                        PhosphorIconsFill.navigationArrow,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Start Live Tracking',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

