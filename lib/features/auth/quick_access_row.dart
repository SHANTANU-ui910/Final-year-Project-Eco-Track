import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'design_tokens.dart';

/// Quick Access Section:
/// 1. "FAST INSTANT ACCESS" divider
/// 2. Luxury Full-Width "Continue with Google" button
/// 3. Dual equal-width 52px buttons for "1-Tap Demo" and "Biometric" authentication
class QuickAccessRow extends StatefulWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback? onAppleTap;
  final VoidCallback? onMicrosoftTap;
  final VoidCallback onDemoTap;
  final VoidCallback onBiometricSuccess;
  final bool isDark;

  const QuickAccessRow({
    super.key,
    required this.onGoogleTap,
    this.onAppleTap,
    this.onMicrosoftTap,
    required this.onDemoTap,
    required this.onBiometricSuccess,
    this.isDark = false,
  });

  @override
  State<QuickAccessRow> createState() => _QuickAccessRowState();
}

class _QuickAccessRowState extends State<QuickAccessRow>
    with SingleTickerProviderStateMixin {
  bool _isGoogleConnecting = false;

  void _triggerGoogleAuth() async {
    if (_isGoogleConnecting) return;
    HapticFeedback.lightImpact();

    setState(() {
      _isGoogleConnecting = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    setState(() {
      _isGoogleConnecting = false;
    });

    widget.onGoogleTap();
  }

  void _triggerSocialAuth(String provider, VoidCallback? callback) async {
    HapticFeedback.lightImpact();
    if (callback != null) {
      callback();
    } else {
      widget.onGoogleTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. "OR CONTINUE WITH" Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : EcoTokens.border,
                thickness: 1.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'OR CONTINUE WITH',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  fontSize: 9.5,
                  color: isDark ? Colors.white.withValues(alpha: 0.5) : EcoTokens.muted,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : EcoTokens.border,
                thickness: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // 2. Three Circular Social Auth Buttons (Google, Apple, Microsoft)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Button
            _CircularSocialButton(
              isDark: isDark,
              isLoading: _isGoogleConnecting,
              onTap: _triggerGoogleAuth,
              child: const GoogleLogo(size: 22.0),
            ),
            const SizedBox(width: 16.0),

            // Apple Button
            _CircularSocialButton(
              isDark: isDark,
              onTap: () => _triggerSocialAuth('Apple', widget.onAppleTap),
              child: Icon(
                Icons.apple,
                size: 24.0,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(width: 16.0),

            // Microsoft Button
            _CircularSocialButton(
              isDark: isDark,
              onTap: () => _triggerSocialAuth('Microsoft', widget.onMicrosoftTap),
              child: const MicrosoftLogo(size: 18.0),
            ),
          ],
        ),
        const SizedBox(height: 14.0),

        // 3. 1-Tap Demo Jump Link
        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onDemoTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bolt,
                    size: 15.0,
                    color: Color(0xFFFACC15), // Amber
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    'Or jump in with 1-Tap Demo Account',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF86EFAC) : EcoTokens.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Circular Social Glass Button (52x52)
class _CircularSocialButton extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final VoidCallback onTap;
  final Widget child;

  const _CircularSocialButton({
    required this.isDark,
    this.isLoading = false,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        customBorder: const CircleBorder(),
        splashColor: const Color(0xFF22C55E).withValues(alpha: 0.15),
        child: Container(
          width: 52.0,
          height: 52.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : EcoTokens.border,
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

/// 4-Color Microsoft Logo Vector (2x2 Grid)
class MicrosoftLogo extends StatelessWidget {
  final double size;
  const MicrosoftLogo({super.key, this.size = 18.0});

  @override
  Widget build(BuildContext context) {
    final half = (size - 2.5) / 2;
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: half, height: half, color: const Color(0xFFF25022)),
              Container(width: half, height: half, color: const Color(0xFF7FBA00)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: half, height: half, color: const Color(0xFF00A4EF)),
              Container(width: half, height: half, color: const Color(0xFFFFB900)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Official 4-Color Google Sign-In Button (52px Luxury Card)
class _GoogleSignInButton extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final VoidCallback onTap;

  const _GoogleSignInButton({
    required this.isDark,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(EcoTokens.radiusButton),
        splashColor: (isDark ? EcoTokens.limeGlow : EcoTokens.primary).withValues(alpha: 0.12),
        highlightColor: (isDark ? EcoTokens.limeGlow : EcoTokens.primary).withValues(alpha: 0.06),
        child: Container(
          height: 52.0,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C241D) : Colors.white,
            borderRadius: BorderRadius.circular(EcoTokens.radiusButton),
            border: Border.all(
              color: isDark ? EcoTokens.darkBorder : EcoTokens.border,
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? EcoTokens.limeGlow : EcoTokens.primary,
                    ),
                  ),
                )
              else
                const GoogleLogo(size: 20.0),
              const SizedBox(width: 12.0),
              Text(
                isLoading ? 'Connecting to Google...' : 'Continue with Google',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: isDark ? EcoTokens.darkInk : EcoTokens.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standalone 4-Color Google "G" Vector Icon (0 KB Asset Size)
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / 2;
    final center = Offset(c, c);
    final thickness = size.width * 0.23;
    final r = (size.width - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: r);

    // Official Google Brand Colors
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..isAntiAlias = true;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..isAntiAlias = true;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..isAntiAlias = true;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..isAntiAlias = true;

    // 1. Red Top Arc (195 deg to 315 deg)
    canvas.drawArc(rect, -math.pi * 0.92, math.pi * 0.65, false, redPaint);

    // 2. Yellow Left Arc (125 deg to 200 deg)
    canvas.drawArc(rect, -math.pi * 1.30, math.pi * 0.42, false, yellowPaint);

    // 3. Green Bottom Arc (40 deg to 130 deg)
    canvas.drawArc(rect, math.pi * 0.22, math.pi * 0.50, false, greenPaint);

    // 4. Blue Right Arc & Horizontal Crossbar
    canvas.drawArc(rect, -math.pi * 0.25, math.pi * 0.48, false, bluePaint);

    final blueFill = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final barHeight = thickness * 0.95;
    final barRect = Rect.fromLTWH(
      c - 1.0,
      c - barHeight / 2,
      c + 1.0,
      barHeight,
    );
    canvas.drawRect(barRect, blueFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickButton extends StatelessWidget {
  final PhosphorIconData icon;
  final Color iconColor;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EcoTokens.radiusButton),
        splashColor: (isDark ? EcoTokens.limeGlow : EcoTokens.primary).withValues(alpha: 0.12),
        highlightColor: (isDark ? EcoTokens.limeGlow : EcoTokens.primary).withValues(alpha: 0.06),
        child: Container(
          height: 52.0,
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF091C16) : Colors.white,
            borderRadius: BorderRadius.circular(EcoTokens.radiusButton),
            border: Border.all(
              color: isDark ? EcoTokens.darkBorder : EcoTokens.border,
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.03),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhosphorIcon(
                icon,
                size: EcoTokens.iconSize,
                color: iconColor,
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? EcoTokens.darkInk : EcoTokens.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dynamic laser scan wave and expanding ring across biometric button
class _BiometricScanPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _BiometricScanPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final accentColor = isDark ? EcoTokens.limeGlow : EcoTokens.primary;

    // Sweeping laser scanline
    final scanY = (progress * (h + 20.0)) - 10.0;
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          accentColor.withValues(alpha: 0.75),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, scanY - 3, w, 6))
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(0, scanY), Offset(w, scanY), beamPaint);

    // Expanding pulsing border ring
    final borderPaint = Paint()
      ..color = accentColor.withValues(alpha: (1.0 - progress) * 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        const Radius.circular(EcoTokens.radiusButton),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BiometricScanPainter old) =>
      old.progress != progress;
}
