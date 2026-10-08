import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'kinematic_engine/bike_painter.dart';
import 'kinematic_engine/bus_painter.dart';
import 'kinematic_engine/car_painter.dart';
import 'kinematic_engine/design_tokens.dart';
import 'kinematic_engine/scene_painter.dart';
import 'kinematic_engine/scooty_painter.dart';
import 'speed_arc_gauge.dart';

/// Unified Cockpit Hero Card merging the 240° Speed Arc Gauge and Kinematic Scene into one master card.
class LiveHeroCard extends StatefulWidget {
  final String selectedMode;
  final double currentSpeedKmh;
  final bool isGpsLocked;
  final String gpsStatusText;
  final bool isStationary;
  final bool isDark;

  const LiveHeroCard({
    super.key,
    required this.selectedMode,
    required this.currentSpeedKmh,
    this.isGpsLocked = true,
    this.gpsStatusText = 'GPS Locked (±3m)',
    this.isStationary = true,
    this.isDark = false,
  });

  @override
  State<LiveHeroCard> createState() => _LiveHeroCardState();
}

class _LiveHeroCardState extends State<LiveHeroCard> with TickerProviderStateMixin {
  late final AnimationController _engineLoopController;
  late final AnimationController _glareSweepController;
  late final AnimationController _taillightController;
  late final AnimationController _radarPingController;

  double _wheelAngle = 0.0;
  double _parallaxProgress = 0.0;
  DateTime _lastFrameTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // 60fps continuous simulation tick for parallax, wheels, and suspension idle bob
    _engineLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_onEngineTick)..repeat();

    // Specular glass glare sweep every 4.5 seconds (600ms sweep)
    _glareSweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();

    // 1.6s pulsing LED taillight
    _taillightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // 1.6s radar ping for GPS searching
    _radarPingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  void _onEngineTick() {
    final now = DateTime.now();
    final dt = now.difference(_lastFrameTime).inMicroseconds / 1000000.0;
    _lastFrameTime = now;

    // Movement rate bound to vehicle velocity (fallback minimal drift when moving)
    final velocityRatio = (widget.currentSpeedKmh / 60.0).clamp(0.0, 3.0);
    final speedFactor = widget.isStationary ? 0.0 : (velocityRatio < 0.1 ? 0.15 : velocityRatio);

    if (mounted) {
      setState(() {
        _wheelAngle = (_wheelAngle + (speedFactor * dt * 14.0)) % (2 * math.pi);
        _parallaxProgress = (_parallaxProgress + (speedFactor * dt * 0.4)) % 1.0;
      });
    }
  }

  @override
  void dispose() {
    _engineLoopController.dispose();
    _glareSweepController.dispose();
    _taillightController.dispose();
    _radarPingController.dispose();
    super.dispose();
  }

  VehicleModule _getModule(String mode) {
    switch (mode.toLowerCase()) {
      case 'scooty':
        return VehicleModule.scooty;
      case 'bike':
        return VehicleModule.bike;
      case 'bus':
        return VehicleModule.bus;
      case 'car':
      default:
        return VehicleModule.car;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxSpeed = EcoDesignTokens.getVehicleGaugeMax(widget.selectedMode);
    final modeKey = widget.selectedMode.toLowerCase();
    final vehicleTokens = ModuleThemeTokens.of(_getModule(widget.selectedMode));

    // Glare sweep occurs during first 600ms of the 4500ms cycle
    final rawGlareVal = _glareSweepController.value;
    final glareSweepPhase = (rawGlareVal * (4500 / 600)).clamp(0.0, 1.0);

    // Idle vertical suspension float
    final idleBob = widget.isStationary ? math.sin(_engineLoopController.value * 2 * math.pi) * 1.5 : 0.0;

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDark ? EcoDesignTokens.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(EcoDesignTokens.radiusCard),
          border: Border.all(
            color: widget.isDark ? EcoDesignTokens.darkBorder : EcoDesignTokens.border,
            width: 1.2,
          ),
          boxShadow: EcoDesignTokens.heroElevation,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(EcoDesignTokens.radiusCard),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ================= 1. TOP: KINEMATIC VEHICLE SCENE (Car, Bike, Scooty, Bus) =================
              SizedBox(
                height: 110,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Parallax Scene
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ScenePainter(
                          tokens: vehicleTokens,
                          parallaxProgress: _parallaxProgress,
                          idleBobOffset: idleBob,
                        ),
                      ),
                    ),

                    // Dedicated Active Vehicle Scene
                    Positioned.fill(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: KeyedSubtree(
                          key: ValueKey(modeKey),
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _buildVehiclePainter(modeKey, vehicleTokens, idleBob, glareSweepPhase),
                          ),
                        ),
                      ),
                    ),

                    // Top-right mini badge
                    Positioned(
                      top: 7,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: (widget.isDark ? EcoDesignTokens.darkSurface : Colors.white).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(EcoDesignTokens.radiusPill),
                          border: Border.all(
                            color: widget.isDark ? EcoDesignTokens.darkBorder : EcoDesignTokens.border,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          widget.selectedMode.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: vehicleTokens.primaryAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= 2. BOTTOM: VELOCITY METER (BELOW THE VEHICLE MODEL) =================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: widget.isDark ? const Color(0xFF091913) : const Color(0xFFF9FCFA),
                  border: Border(
                    top: BorderSide(
                      color: widget.isDark ? EcoDesignTokens.darkBorder : EcoDesignTokens.border,
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Speed Numeral Display
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          widget.currentSpeedKmh.toStringAsFixed(1),
                          style: EcoDesignTokens.heroSpeed(isDark: widget.isDark).copyWith(fontSize: 30.0, height: 1.0),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'km/h',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: widget.isDark ? EcoDesignTokens.darkMuted : EcoDesignTokens.muted,
                          ),
                        ),
                      ],
                    ),

                    // Compact Speed Arc Gauge
                    SizedBox(
                      width: 85,
                      height: 52,
                      child: SpeedArcGauge(
                        currentSpeedKmh: widget.currentSpeedKmh,
                        maxSpeedKmh: maxSpeed,
                        isDark: widget.isDark,
                        isCompact: true,
                      ),
                    ),

                    // GPS Status Chip
                    _buildGpsChip(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CustomPainter _buildVehiclePainter(
    String mode,
    ModuleThemeTokens tokens,
    double idleBob,
    double glareSweep,
  ) {
    switch (mode) {
      case 'scooty':
        return ScootyPainter(
          tokens: tokens,
          wheelAngle: _wheelAngle,
          idleBob: idleBob,
          taillightPulse: _taillightController.value,
          glareSweepPhase: glareSweep,
        );
      case 'bike':
        return BikePainter(
          tokens: tokens,
          wheelAngle: _wheelAngle,
          idleBob: idleBob,
          taillightPulse: _taillightController.value,
          glareSweepPhase: glareSweep,
        );
      case 'bus':
        return BusPainter(
          tokens: tokens,
          wheelAngle: _wheelAngle,
          idleBob: idleBob,
          taillightPulse: _taillightController.value,
          glareSweepPhase: glareSweep,
        );
      case 'car':
      default:
        return CarPainter(
          tokens: tokens,
          wheelAngle: _wheelAngle,
          idleBob: idleBob,
          taillightPulse: _taillightController.value,
          glareSweepPhase: glareSweep,
        );
    }
  }

  Widget _buildGpsChip() {
    final isLocked = widget.isGpsLocked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.5),
      decoration: BoxDecoration(
        color: isLocked
            ? (widget.isDark ? const Color(0xFF10281E) : const Color(0xFFEAF5EE))
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
            Container(
              width: 6.5,
              height: 6.5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: EcoDesignTokens.bright,
              ),
            )
          else
            AnimatedBuilder(
              animation: _radarPingController,
              builder: (context, _) {
                final scale = 1.0 + (_radarPingController.value * 0.8);
                final opacity = (1.0 - _radarPingController.value) * 0.7;
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
          const SizedBox(width: 6.0),
          Text(
            isLocked ? widget.gpsStatusText : 'Locking GPS...',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11.0,
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
