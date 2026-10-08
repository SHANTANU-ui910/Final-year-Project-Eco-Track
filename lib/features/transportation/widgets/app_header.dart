import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/design_tokens.dart';

/// 56dp elite sticky header with squircle logo, tagline fade, user avatar, and 3 glass actions
class AppHeader extends StatefulWidget {
  final double scrollOffset;
  final String userName;
  final bool isSyncing;
  final VoidCallback onUserTap;
  final VoidCallback onSyncTap;
  final VoidCallback onReportTap;
  final VoidCallback onRecenterTap;
  final bool isDark;

  const AppHeader({
    super.key,
    required this.scrollOffset,
    this.userName = 'Alex M.',
    this.isSyncing = false,
    required this.onUserTap,
    required this.onSyncTap,
    required this.onReportTap,
    required this.onRecenterTap,
    this.isDark = false,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> with SingleTickerProviderStateMixin {
  late final AnimationController _syncRotateController;

  @override
  void initState() {
    super.initState();
    _syncRotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isSyncing) {
      _syncRotateController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AppHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing && !_syncRotateController.isAnimating) {
      _syncRotateController.repeat();
    } else if (!widget.isSyncing && _syncRotateController.isAnimating) {
      _syncRotateController.stop();
      _syncRotateController.reset();
    }
  }

  @override
  void dispose() {
    _syncRotateController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'AM';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Header elevates and blurs slightly as user scrolls down
    final scrollRatio = (widget.scrollOffset / 32.0).clamp(0.0, 1.0);
    final taglineOpacity = (1.0 - (widget.scrollOffset / 18.0)).clamp(0.0, 1.0);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: scrollRatio * 16.0,
          sigmaY: scrollRatio * 16.0,
        ),
        child: Container(
          height: 56.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: widget.isDark
                ? EcoDesignTokens.darkBg.withValues(alpha: 0.70 + (scrollRatio * 0.25))
                : EcoDesignTokens.mintBg.withValues(alpha: 0.75 + (scrollRatio * 0.20)),
            border: Border(
              bottom: BorderSide(
                color: widget.isDark
                    ? EcoDesignTokens.darkBorder.withValues(alpha: scrollRatio)
                    : EcoDesignTokens.border.withValues(alpha: scrollRatio),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            children: [
              // 40dp Squircle Brand Logo Tile + Wordmark
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.isDark ? EcoDesignTokens.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: widget.isDark ? EcoDesignTokens.darkBorder : const Color(0xFFD4E6DC),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: EcoDesignTokens.primary.withValues(alpha: 0.12),
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIconsFill.footprints,
                        size: 22,
                        color: widget.isDark ? EcoDesignTokens.limeGlow : EcoDesignTokens.deepEmerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Eco',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: widget.isDark ? EcoDesignTokens.darkInk : EcoDesignTokens.deepEmerald,
                            ),
                          ),
                          const Text(
                            'Track',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 18.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: EcoDesignTokens.bright,
                            ),
                          ),
                        ],
                      ),
                      if (taglineOpacity > 0.05)
                        Opacity(
                          opacity: taglineOpacity,
                          child: Text(
                            '— Small Steps. Big Impact. —',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark ? EcoDesignTokens.darkMuted : EcoDesignTokens.muted,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // User Initials Avatar with Live Pulse Dot
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onUserTap();
                },
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: widget.isDark ? EcoDesignTokens.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(EcoDesignTokens.radiusPill),
                    border: Border.all(
                      color: widget.isDark ? EcoDesignTokens.darkBorder : EcoDesignTokens.border,
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: EcoDesignTokens.bright,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getInitials(widget.userName),
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark ? EcoDesignTokens.darkInk : EcoDesignTokens.deepEmerald,
                        ),
                      ),
                      const SizedBox(width: 4),
                      PhosphorIcon(
                        PhosphorIconsRegular.lockKey,
                        size: 13,
                        color: widget.isDark ? EcoDesignTokens.darkMuted : EcoDesignTokens.muted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 3 Unified 44dp Glass Action Buttons (Sync, Report, Recenter)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Sync Button (Rotates while syncing)
                  _buildGlassActionButton(
                    tooltip: 'Sync carbon ledger',
                    icon: RotationTransition(
                      turns: _syncRotateController,
                      child: PhosphorIcon(
                        PhosphorIconsRegular.arrowsClockwise,
                        size: 19,
                        color: widget.isSyncing
                            ? EcoDesignTokens.bright
                            : (widget.isDark ? EcoDesignTokens.darkInk : EcoDesignTokens.deepEmerald),
                      ),
                    ),
                    onTap: widget.onSyncTap,
                  ),
                  const SizedBox(width: 6),

                  // 2. Report Button
                  _buildGlassActionButton(
                    tooltip: 'Audit ledger report',
                    icon: PhosphorIcon(
                      PhosphorIconsRegular.fileText,
                      size: 19,
                      color: widget.isDark ? EcoDesignTokens.darkInk : EcoDesignTokens.deepEmerald,
                    ),
                    onTap: widget.onReportTap,
                  ),
                  const SizedBox(width: 6),

                  // 3. Recenter Map Button
                  _buildGlassActionButton(
                    tooltip: 'Recenter GPS location',
                    icon: PhosphorIcon(
                      PhosphorIconsRegular.crosshair,
                      size: 19,
                      color: widget.isDark ? EcoDesignTokens.darkInk : EcoDesignTokens.deepEmerald,
                    ),
                    onTap: widget.onRecenterTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassActionButton({
    required String tooltip,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.isDark ? EcoDesignTokens.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isDark ? EcoDesignTokens.darkBorder : EcoDesignTokens.border,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: widget.isDark ? 0.20 : 0.04),
                  offset: const Offset(0, 1.5),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}
