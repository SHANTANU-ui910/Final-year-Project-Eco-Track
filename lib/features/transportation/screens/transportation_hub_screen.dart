import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/tracking_provider.dart';
import '../providers/trip_history_provider.dart';
import '../widgets/trip_card_widget.dart';
import 'live_tracking_screen.dart';
import 'trip_detail_screen.dart';
import 'trip_history_screen.dart';
import 'vehicle_selector_screen.dart';

class TransportationHubScreen extends ConsumerWidget {
  const TransportationHubScreen({super.key});

  /// Single-Tap Instant Start with Automatic Sensor & GPS Mode Classification
  Future<void> _handleInstantStartAutoDetect(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(trackingProvider.notifier)
        .startTrip(autoDetect: true);

    if (success && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LiveTrackingScreen(),
        ),
      );
    }
  }

  /// Optional Manual Override
  Future<void> _handleManualOverride(BuildContext context, WidgetRef ref) async {
    final selectedVehicle = await VehicleSelectorSheet.show(context);
    if (selectedVehicle == null) return;

    final success = await ref
        .read(trackingProvider.notifier)
        .startTrip(explicitType: selectedVehicle, autoDetect: false);

    if (success && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LiveTrackingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripHistoryProvider);
    final historyNotifier = ref.read(tripHistoryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transportation', style: AppTextStyles.displayMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Autonomous GPS & carbon mobility tracker',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warmGray),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: AppColors.forestGreen,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Autonomous Smart Start Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.forestGreen, Color(0xFF2D6A4F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.forestGreen.withValues(alpha: 0.28),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'AUTO SENSOR ENGINE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _handleManualOverride(context, ref),
                          child: const Text(
                            'Manual Override',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Zero-Touch Tracking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Just tap Start. Real-time GPS kinematics auto-detect whether you are walking, cycling, riding a bus, or driving an EV.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.forestGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _handleInstantStartAutoDetect(context, ref),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow_rounded, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              'Start Trip (Auto-Detect Mode)',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.forestGreen,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Overview Stats Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mobility Impact', style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _metricColumn(
                          'Total Distance',
                          '${historyNotifier.totalDistanceKm.toStringAsFixed(1)} km',
                          AppColors.charcoal,
                        ),
                        _metricColumn(
                          'CO₂ Emitted',
                          '${historyNotifier.totalCo2EmissionsKg.toStringAsFixed(2)} kg',
                          AppColors.alertRed,
                        ),
                        _metricColumn(
                          'CO₂ Avoided',
                          '${historyNotifier.totalCarbonSavedKg.toStringAsFixed(2)} kg',
                          AppColors.sage,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Trips section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Trips', style: AppTextStyles.headlineLarge),
                  if (trips.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TripHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: AppColors.forestGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Trips List
              if (trips.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 40,
                          color: AppColors.warmGray.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No trips logged yet',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.warmGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...trips.take(3).map(
                      (trip) => TripCardWidget(
                        trip: trip,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TripDetailScreen(trip: trip),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
