import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/login_screen.dart';
import '../models/vehicle_type.dart';
import '../providers/tracking_provider.dart';
import '../theme/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_dock.dart';
import '../widgets/live_hero_card.dart';
import '../widgets/stats_tiles.dart';
import '../widgets/styled_map_card.dart';
import '../widgets/vehicle_context_strip.dart';
import '../widgets/vehicle_selector.dart';
import 'trip_summary_screen.dart';

/// Complete Redesigned EcoTrack Main Tracking Screen (Fintech / Climate Elite Standard)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  final bool _isDark = false;
  String _selectedMode = 'car';

  // Staggered Entrance Controller (< 1.2s total)
  late final AnimationController _entranceController;
  late final Animation<double> _headerEntrance;
  late final Animation<double> _selectorEntrance;
  late final Animation<double> _stripEntrance;
  late final Animation<double> _heroEntrance;
  late final Animation<double> _statsEntrance;
  late final Animation<double> _mapEntrance;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );

    _headerEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.00, 0.40, curve: Curves.easeOutCubic),
    );
    _selectorEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.08, 0.48, curve: Curves.easeOutCubic),
    );
    _stripEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.14, 0.58, curve: Curves.easeOutCubic),
    );
    _mapEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.20, 0.72, curve: Curves.easeOutCubic),
    );
    _statsEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.28, 0.80, curve: Curves.easeOutCubic),
    );
    _heroEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.36, 1.00, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _onStopTrip() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _isDark ? EcoDesignTokens.darkSurface : Colors.white,
        title: Text(
          'Complete Trip?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            color: _isDark ? EcoDesignTokens.darkInk : EcoDesignTokens.deepEmerald,
          ),
        ),
        content: Text(
          'Are you sure you want to finish this trip and record your verified carbon footprint?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: _isDark ? EcoDesignTokens.darkMuted : EcoDesignTokens.muted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Keep Tracking',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                color: _isDark ? EcoDesignTokens.darkMuted : EcoDesignTokens.muted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: EcoDesignTokens.deepEmerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              final trip = ref.read(trackingProvider.notifier).stopTrip();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => TripSummaryScreen(trip: trip),
                ),
              );
            },
            child: const Text(
              'Finish Trip',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _handleModeSelection(String mode) {
    setState(() {
      _selectedMode = mode;
    });

    // Sync mode with underlying Riverpod tracking state without modifying logic
    VehicleType targetType = VehicleType.petrolCar;
    if (mode == 'scooty') targetType = VehicleType.scooter;
    if (mode == 'bike') targetType = VehicleType.motorcycle;
    if (mode == 'bus') targetType = VehicleType.bus;

    ref.read(trackingProvider.notifier).setVehicleType(targetType);
  }

  void _showReportBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: _isDark ? EcoDesignTokens.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Trip & Carbon Audit Report',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _isDark ? EcoDesignTokens.darkInk : EcoDesignTokens.deepEmerald,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your mobility emissions are audited using IPCC Tier-1 coefficients and cryptographically stamped for ESG certification.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: _isDark ? EcoDesignTokens.darkMuted : EcoDesignTokens.muted,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EcoDesignTokens.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close Report',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(trackingProvider);
    final notifier = ref.read(trackingProvider.notifier);

    final isTracking = tracking.status == TrackingStatus.tracking;
    final isPaused = tracking.status == TrackingStatus.paused;
    final isStationary = tracking.currentSpeedKmh < 1.0;

    // Active metadata
    final vehicleName = _selectedMode == 'scooty'
        ? 'Scooty'
        : _selectedMode == 'bike'
            ? 'Bike'
            : _selectedMode == 'bus'
                ? 'Public Bus'
                : 'Car';

    final categoryBadge = _selectedMode == 'scooty'
        ? 'Light Moped'
        : _selectedMode == 'bike'
            ? 'Commuter'
            : _selectedMode == 'bus'
                ? 'Transit Coach'
                : 'Passenger Vehicle';

    final vehicleDesc = _selectedMode == 'scooty'
        ? 'Efficient urban runabout'
        : _selectedMode == 'bike'
            ? 'Agile commuter cycle'
            : _selectedMode == 'bus'
                ? 'High-capacity shared transit'
                : 'Standard passenger vehicle';

    final emissionFactor = _selectedMode == 'scooty'
        ? 0.0540
        : _selectedMode == 'bike'
            ? 0.0820
            : _selectedMode == 'bus'
                ? 0.0380
                : 0.1710;

    return Scaffold(
      backgroundColor: _isDark ? EcoDesignTokens.darkBg : EcoDesignTokens.mintBg,
      body: Stack(
        children: [
          // Main Scrollable Telemetry Viewport
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 56.0, bottom: 84.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Vehicle Selector (sliding spring pill)
                    _buildEntrance(
                      animation: _selectorEntrance,
                      child: VehicleSelector(
                        selectedMode: _selectedMode,
                        onModeChanged: _handleModeSelection,
                        isDark: _isDark,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // 2. Vehicle Context Strip (Accent bar, 1-line emission, mini intensity)
                    _buildEntrance(
                      animation: _stripEntrance,
                      child: VehicleContextStrip(
                        modeKey: _selectedMode,
                        vehicleName: vehicleName,
                        categoryBadge: categoryBadge,
                        description: vehicleDesc,
                        emissionFactor: emissionFactor,
                        isDark: _isDark,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // 3. Styled Map Card (180dp, custom mint/slate palette, polyline glow)
                    _buildEntrance(
                      animation: _mapEntrance,
                      child: StyledMapCard(
                        height: 180.0,
                        points: tracking.routePoints,
                        isTracking: isTracking,
                        isGpsLocked: tracking.routePoints.isNotEmpty,
                        isDark: _isDark,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // 4. Stats Tiles (3 Separate Glass Tiles: Distance, Emissions, Duration)
                    _buildEntrance(
                      animation: _statsEntrance,
                      child: StatsTiles(
                        distanceKm: tracking.distanceKm,
                        emissionsKg: tracking.co2EmissionsKg,
                        durationSeconds: tracking.elapsedDuration.inSeconds,
                        isRunning: isTracking,
                        isDark: _isDark,
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    // 5. Live Hero Card (Unified Side-by-Side 240° Arc Gauge + Kinematic Scene)
                    _buildEntrance(
                      animation: _heroEntrance,
                      child: LiveHeroCard(
                        selectedMode: _selectedMode,
                        currentSpeedKmh: tracking.currentSpeedKmh,
                        isGpsLocked: tracking.routePoints.isNotEmpty,
                        gpsStatusText: tracking.routePoints.isNotEmpty ? 'GPS Locked (±3m)' : 'Locking GPS...',
                        isStationary: isStationary,
                        isDark: _isDark,
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Sticky Top Header (56dp with scroll blur hairline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildEntrance(
              animation: _headerEntrance,
              child: SafeArea(
                bottom: false,
                child: AppHeader(
                  scrollOffset: _scrollOffset,
                  userName: 'Alex M.',
                  onUserTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  onSyncTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Trips synchronized with IPCC Tier-1 Ledger'),
                        backgroundColor: EcoDesignTokens.deepEmerald,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  onReportTap: _showReportBottomSheet,
                  onRecenterTap: () {},
                  isDark: _isDark,
                ),
              ),
            ),
          ),

          // Floating Bottom Dock (64dp with primary trip actions)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomDock(
              isTracking: isTracking,
              isPaused: isPaused,
              onStartOrResume: () {
                if (isPaused) {
                  notifier.resumeTrip();
                } else {
                  notifier.startTrip();
                }
              },
              onPause: notifier.pauseTrip,
              onStop: _onStopTrip,
              isDark: _isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntrance({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        final offsetY = (1.0 - progress) * 20.0;

        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Opacity(
            opacity: progress,
            child: child,
          ),
        );
      },
    );
  }
}
