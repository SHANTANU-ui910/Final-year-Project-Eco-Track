import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/vehicle_type.dart';
import '../providers/tracking_provider.dart';
import '../widgets/carbon_chart_widget.dart';
import '../widgets/live_map_widget.dart';
import '../widgets/live_metrics_widget.dart';
import '../widgets/trip_controls_widget.dart';
import '../widgets/vehicle_animation_widget.dart';
import 'trip_summary_screen.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  bool _showMap = true;

  void _onStopTrip() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Complete Trip?'),
        content: const Text(
          'Are you sure you want to finish this trip and record your carbon footprint?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Tracking', style: TextStyle(color: AppColors.warmGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            child: const Text('Finish Trip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(trackingProvider);
    final notifier = ref.read(trackingProvider.notifier);
    final isPaused = tracking.status == TrackingStatus.paused;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tracking.vehicleType.iconData,
                    color: AppColors.forestGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  tracking.vehicleType.displayName,
                  style: AppTextStyles.headlineMedium.copyWith(fontSize: 16),
                ),
              ],
            ),
            if (tracking.isAutoDetectEnabled)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.paleSage,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'AI Auto-Detected Mode',
                      style: TextStyle(
                        color: AppColors.forestGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _showMap ? 'Hide Map' : 'Show Map',
            icon: Icon(
              _showMap ? Icons.map_rounded : Icons.map_outlined,
              color: AppColors.forestGreen,
            ),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  children: [
                    // Dynamic Vehicle Animation Canvas
                    Center(
                      child: VehicleAnimationWidget(
                        currentSpeedKmh: tracking.currentSpeedKmh,
                        vehicleType: tracking.vehicleType,
                        isMoving:
                            tracking.status == TrackingStatus.tracking &&
                                tracking.currentSpeedKmh > 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Primary Live Metrics Grid
                    LiveMetricsWidget(
                      speedKmh: tracking.currentSpeedKmh,
                      distanceKm: tracking.distanceKm,
                      co2EmissionsKg: tracking.co2EmissionsKg,
                      elapsedDuration: tracking.elapsedDuration,
                    ),
                    const SizedBox(height: 16),

                    // Real-Time Carbon Chart
                    CarbonChartWidget(
                      currentCarbonKg: tracking.co2EmissionsKg,
                    ),
                    const SizedBox(height: 16),

                    // Collapsible Live Route Map
                    if (_showMap)
                      SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: LiveMapWidget(
                          points: tracking.routePoints,
                          isTracking:
                              tracking.status == TrackingStatus.tracking,
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Trip Floating Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              child: TripControlsWidget(
                isPaused: isPaused,
                onPauseResume: () {
                  if (isPaused) {
                    notifier.resumeTrip();
                  } else {
                    notifier.pauseTrip();
                  }
                },
                onStop: _onStopTrip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
