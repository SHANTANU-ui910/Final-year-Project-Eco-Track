import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'scene_painter.dart';
import 'scooty_painter.dart';
import 'car_painter.dart';
import 'bike_painter.dart';
import 'bus_painter.dart';

/// Kinematic Vehicle Engine Card: A high-performance, automotive-grade
/// animated showcase featuring dynamic parallax layers, module-specific vehicle
/// rendering, realistic lighting effects, and micro-interactions.
class VehicleAnimationCard extends StatefulWidget {
  final VehicleModule module;
  final double currentSpeedKmh;
  final bool isMoving;
  final double height;
  final VoidCallback? onTap;

  const VehicleAnimationCard({
    super.key,
    required this.module,
    this.currentSpeedKmh = 45.0,
    this.isMoving = true,
    this.height = 210.0,
    this.onTap,
  });

  @override
  State<VehicleAnimationCard> createState() => _VehicleAnimationCardState();
}

class _VehicleAnimationCardState extends State<VehicleAnimationCard>
    with TickerProviderStateMixin {
  // Continuous master ticker for 60fps scene loops
  late AnimationController _masterLoopController;

  // Glare sweep ticker (sweeps across windshield every 5 seconds)
  late AnimationController _glareController;

  // Interactive tap bounce & glow controller (250ms spring)
  late AnimationController _tapFeedbackController;
  late Animation<double> _tapScaleAnimation;
  late Animation<double> _tapGlowAnimation;

  // Running cumulative wheel rotation angle in radians
  double _wheelAngle = 0.0;
  // Cumulative parallax offset
  double _parallaxOffset = 0.0;

  DateTime _lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // 1. Master continuous animation loop (4s repeat period)
    _masterLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..addListener(_onMasterTick);

    // 2. Window glare sweep (5s interval)
    _glareController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // 3. Tap feedback animation (250ms bounce)
    _tapFeedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _tapScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.03)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.03, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 60.0,
      ),
    ]).animate(_tapFeedbackController);

    _tapGlowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 65.0,
      ),
    ]).animate(_tapFeedbackController);

    _startAnimations();
  }

  void _startAnimations() {
    _masterLoopController.repeat();
    _glareController.repeat();
    _lastFrameTime = DateTime.now();
  }

  void _onMasterTick() {
    final now = DateTime.now();
    final dt = now.difference(_lastFrameTime).inMicroseconds / 1000000.0;
    _lastFrameTime = now;

    // Calculate speed factor
    final speed = widget.isMoving ? widget.currentSpeedKmh.clamp(5.0, 140.0) : 0.0;

    // Angular velocity: omega = v / r (normalized for aesthetic wheel spin)
    final wheelSpeed = (speed * 0.28) * dt * 10.0;
    _wheelAngle = (_wheelAngle + wheelSpeed) % (2 * math.pi);

    // Parallax ground speed
    final roadSpeed = (speed / 70.0) * dt;
    _parallaxOffset = (_parallaxOffset + roadSpeed) % 1.0;
  }

  @override
  void didUpdateWidget(covariant VehicleAnimationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMoving != oldWidget.isMoving) {
      _lastFrameTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    _masterLoopController.removeListener(_onMasterTick);
    _masterLoopController.dispose();
    _glareController.dispose();
    _tapFeedbackController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapFeedbackController.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = ModuleThemeTokens.of(widget.module);
    final isReducedMotion = MediaQuery.of(context).disableAnimations;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _masterLoopController,
          _glareController,
          _tapFeedbackController,
        ]),
        builder: (context, child) {
          final t = isReducedMotion ? 0.0 : _masterLoopController.value;
          final glarePhase = isReducedMotion ? 0.0 : _glareController.value;

          // Idle vertical harmonic bobbing (+- 2.4px at ~1.5Hz)
          final idleBob = isReducedMotion
              ? 0.0
              : math.sin(t * 2 * math.pi) * (widget.isMoving ? 2.4 : 1.4);

          // Taillight breathing pulse (0.0 -> 1.0)
          final taillightPulse = (math.sin(t * 4 * math.pi) * 0.5 + 0.5);

          // Tap bounce scale & glow multiplier
          final scale = isReducedMotion ? 1.0 : _tapScaleAnimation.value;
          final glowFactor = _tapGlowAnimation.value;

          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  gradient: tokens.cardBackground,
                  border: Border.all(
                    color: Color.lerp(
                      tokens.cardBorderColor,
                      tokens.primaryAccent,
                      glowFactor * 0.6,
                    )!,
                    width: 1.2 + (glowFactor * 0.8),
                  ),
                  boxShadow: [
                    ...tokens.cardShadows,
                    if (glowFactor > 0.01)
                      BoxShadow(
                        color: tokens.primaryAccent.withValues(alpha: 0.25 * glowFactor),
                        offset: const Offset(0, 8),
                        blurRadius: 28.0,
                        spreadRadius: 2.0,
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.8),
                  child: Stack(
                    children: [
                      // 1. Full Environment Parallax Canvas
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ScenePainter(
                            tokens: tokens,
                            parallaxProgress: isReducedMotion ? 0.0 : _parallaxOffset,
                            idleBobOffset: idleBob,
                            isReducedMotion: isReducedMotion,
                          ),
                        ),
                      ),

                      // 2. Vehicle Switcher Layer (Animated crossfade 350ms)
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.04, 0.0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: KeyedSubtree(
                            key: ValueKey<VehicleModule>(widget.module),
                            child: CustomPaint(
                              painter: _buildVehiclePainter(
                                tokens: tokens,
                                wheelAngle: isReducedMotion ? 0.0 : _wheelAngle,
                                idleBob: idleBob,
                                taillightPulse: taillightPulse,
                                glareSweepPhase: glarePhase,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 3. Top Header: Engine Status Badge & Pulse Indicator
                      Positioned(
                        top: 14.0,
                        left: 16.0,
                        right: 16.0,
                        child: _buildHeaderOverlay(tokens),
                      ),

                      // 4. Bottom Speed Indicator Strip (Subtle telemetry HUD)
                      Positioned(
                        bottom: 12.0,
                        right: 16.0,
                        child: _buildTelemetryHUD(tokens),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the active vehicle painter for the selected module
  CustomPainter _buildVehiclePainter({
    required ModuleThemeTokens tokens,
    required double wheelAngle,
    required double idleBob,
    required double taillightPulse,
    required double glareSweepPhase,
  }) {
    switch (widget.module) {
      case VehicleModule.scooty:
        return ScootyPainter(
          tokens: tokens,
          wheelAngle: wheelAngle,
          idleBob: idleBob,
          taillightPulse: taillightPulse,
          glareSweepPhase: glareSweepPhase,
        );
      case VehicleModule.car:
        return CarPainter(
          tokens: tokens,
          wheelAngle: wheelAngle,
          idleBob: idleBob,
          taillightPulse: taillightPulse,
          glareSweepPhase: glareSweepPhase,
        );
      case VehicleModule.bike:
        return BikePainter(
          tokens: tokens,
          wheelAngle: wheelAngle,
          idleBob: idleBob,
          taillightPulse: taillightPulse,
          glareSweepPhase: glareSweepPhase,
        );
      case VehicleModule.bus:
        return BusPainter(
          tokens: tokens,
          wheelAngle: wheelAngle,
          idleBob: idleBob,
          taillightPulse: taillightPulse,
          glareSweepPhase: glareSweepPhase,
        );
    }
  }

  /// Top header HUD with pulsating engine dot & module title
  Widget _buildHeaderOverlay(ModuleThemeTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Pulsing Engine Dot + Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: tokens.cardBorderColor.withValues(alpha: 0.9),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing Dot
              _PulsingEngineDot(accentColor: tokens.primaryAccent),
              const SizedBox(width: 7.0),
              // Header text
              const Text(
                'KINEMATIC VEHICLE ENGINE',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: Color(0xFF263238),
                ),
              ),
            ],
          ),
        ),

        // Module Badge (SCOOTY, CAR, BIKE, BUS)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
          decoration: BoxDecoration(
            color: tokens.primaryAccent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: tokens.primaryAccent.withValues(alpha: 0.35),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getModuleIcon(widget.module),
                size: 11.0,
                color: tokens.primaryAccent,
              ),
              const SizedBox(width: 5.0),
              Text(
                tokens.displayName.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: tokens.primaryAccent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Subtle telemetry speed indicator in bottom corner
  Widget _buildTelemetryHUD(ModuleThemeTokens tokens) {
    final speed = widget.isMoving ? widget.currentSpeedKmh.toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: tokens.cardBorderColor.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            speed,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 3.0),
          const Text(
            'km/h',
            style: TextStyle(
              fontSize: 9.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getModuleIcon(VehicleModule module) {
    switch (module) {
      case VehicleModule.scooty:
        return Icons.electric_moped_rounded;
      case VehicleModule.car:
        return Icons.directions_car_filled_rounded;
      case VehicleModule.bike:
        return Icons.two_wheeler_rounded;
      case VehicleModule.bus:
        return Icons.directions_bus_filled_rounded;
    }
  }
}

/// Pulsating engine indicator beacon with dual outer aura
class _PulsingEngineDot extends StatefulWidget {
  final Color accentColor;

  const _PulsingEngineDot({required this.accentColor});

  @override
  State<_PulsingEngineDot> createState() => _PulsingEngineDotState();
}

class _PulsingEngineDotState extends State<_PulsingEngineDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOutQuad),
    );

    _pulseOpacity = Tween<double>(begin: 0.65, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10.0,
      height: 10.0,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Expanding ripple
                Transform.scale(
                  scale: _pulseScale.value,
                  child: Container(
                    width: 7.0,
                    height: 7.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.accentColor.withValues(
                        alpha: _pulseOpacity.value,
                      ),
                    ),
                  ),
                ),
                // Solid core
                Container(
                  width: 6.5,
                  height: 6.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.6),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
