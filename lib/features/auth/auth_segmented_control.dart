import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_tokens.dart';

enum AuthTab { signIn, createAccount }

/// Sliding-Pill Segmented Control with spring physics (320ms, damping 0.8)
/// and tactile haptic selection feedback.
class AuthSegmentedControl extends StatelessWidget {
  final AuthTab currentTab;
  final ValueChanged<AuthTab> onTabChanged;
  final bool isDark;

  const AuthSegmentedControl({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSignIn = currentTab == AuthTab.signIn;

    return Container(
      height: 48.0,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF071B14) : const Color(0xFFEAF5EE),
        borderRadius: BorderRadius.circular(EcoTokens.radiusPill),
        border: Border.all(
          color: isDark ? const Color(0xFF133C2E) : const Color(0xFFD6EADB),
          width: 1.0,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pillWidth = (constraints.maxWidth) / 2.0;

          return Stack(
            children: [
              // 1. Sliding Active Solid Pill with Spring Physics
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: const SpringCurve(damping: 0.8),
                left: isSignIn ? 0.0 : pillWidth,
                top: 0.0,
                bottom: 0.0,
                width: pillWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? EcoTokens.primary : EcoTokens.deepEmerald,
                    borderRadius: BorderRadius.circular(EcoTokens.radiusPill),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? EcoTokens.primary : EcoTokens.deepEmerald)
                            .withValues(alpha: 0.28),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Tab Action Labels Row
              Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: 'Sign In',
                      isActive: isSignIn,
                      isDark: isDark,
                      onTap: () {
                        if (!isSignIn) {
                          HapticFeedback.selectionClick();
                          onTabChanged(AuthTab.signIn);
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: _TabButton(
                      label: 'Create Account',
                      isActive: !isSignIn,
                      isDark: isDark,
                      onTap: () {
                        if (isSignIn) {
                          HapticFeedback.selectionClick();
                          onTabChanged(AuthTab.createAccount);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14.0,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: -0.1,
            color: isActive
                ? Colors.white
                : (isDark ? EcoTokens.darkMuted : EcoTokens.muted),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

/// Custom spring simulation curve with tuneable damping
class SpringCurve extends Curve {
  final double damping;

  const SpringCurve({this.damping = 0.8});

  @override
  double transformInternal(double t) {
    // Underdamped spring model approximation
    return 1.0 -
        (1.0 - t) * (1.0 - t) * (1.0 - t) * ((1.0 - damping) * 2.0 + 1.0) +
        (damping * 0.0);
  }
}

