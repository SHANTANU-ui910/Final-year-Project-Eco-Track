import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/trip_model.dart';
import '../models/vehicle_type.dart';
import '../widgets/live_map_widget.dart';

class TripDetailScreen extends StatelessWidget {
  final TripModel trip;

  const TripDetailScreen({
    super.key,
    required this.trip,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final hours = d.inHours;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, yyyy • h:mm a');

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Trip Breakdown'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle & Date Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: trip.vehicleType.isZeroEmission
                          ? AppColors.paleSage
                          : AppColors.lightGray,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      trip.vehicleType.iconData,
                      size: 28,
                      color: trip.vehicleType.isZeroEmission
                          ? AppColors.forestGreen
                          : AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.vehicleType.displayName,
                          style: AppTextStyles.headlineMedium.copyWith(fontSize: 17),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(trip.startTime),
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Map preview with route polyline
            if (trip.routePoints.isNotEmpty) ...[
              Text('Route Traveled', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 10),
              SizedBox(
                height: 240,
                width: double.infinity,
                child: LiveMapWidget(
                  points: trip.routePoints,
                  isTracking: false,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Detailed Metric Statistics
            Text('Statistics', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.6)),
              ),
              child: Column(
                children: [
                  _statRow('Distance', '${trip.distanceKm.toStringAsFixed(2)} km'),
                  const Divider(height: 24),
                  _statRow('Duration', _formatDuration(trip.duration)),
                  const Divider(height: 24),
                  _statRow(
                    'Carbon Emissions',
                    '${trip.co2EmissionsKg.toStringAsFixed(2)} kg CO₂e',
                    textColor: trip.vehicleType.isZeroEmission
                        ? AppColors.sage
                        : AppColors.alertRed,
                  ),
                  const Divider(height: 24),
                  _statRow('Average Speed', '${trip.avgSpeedKmh.toStringAsFixed(1)} km/h'),
                  const Divider(height: 24),
                  _statRow('Max Speed', '${trip.maxSpeedKmh.toStringAsFixed(1)} km/h'),
                  if (trip.carbonSavedKg > 0.0) ...[
                    const Divider(height: 24),
                    _statRow(
                      'Carbon Saved vs Petrol',
                      '${trip.carbonSavedKg.toStringAsFixed(2)} kg CO₂e',
                      textColor: AppColors.forestGreen,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow(String title, String value, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warmGray)),
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: 15,
            color: textColor ?? AppColors.charcoal,
          ),
        ),
      ],
    );
  }
}

