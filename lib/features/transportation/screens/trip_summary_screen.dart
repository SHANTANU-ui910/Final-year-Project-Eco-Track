import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/trip_model.dart';
import '../models/vehicle_type.dart';
import '../providers/tracking_provider.dart';
import '../providers/trip_history_provider.dart';

class TripSummaryScreen extends ConsumerWidget {
  final TripModel trip;

  const TripSummaryScreen({
    super.key,
    required this.trip,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    if (hours > 0) return '$hours h $minutes m';
    return '$minutes m $seconds s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMMM d, yyyy • h:mm a');

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Trip Summary'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success Badge & Mode
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.paleSage,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.forestGreen,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Trip Completed!',
                  style: AppTextStyles.headlineLarge.copyWith(fontSize: 24),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  dateFormat.format(trip.startTime),
                  style: AppTextStyles.labelSmall,
                ),
              ),
              const SizedBox(height: 24),

              // Summary Hero Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.6)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryItem(
                          'DISTANCE',
                          '${trip.distanceKm.toStringAsFixed(2)} km',
                          Icons.straighten_rounded,
                        ),
                        _summaryItem(
                          'DURATION',
                          _formatDuration(trip.duration),
                          Icons.timer_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryItem(
                          'TOTAL CO₂e',
                          '${trip.co2EmissionsKg.toStringAsFixed(2)} kg',
                          Icons.cloud_outlined,
                          isHighlight: true,
                          highlightColor: trip.vehicleType.isZeroEmission
                              ? AppColors.sage
                              : AppColors.alertRed,
                        ),
                        _summaryItem(
                          'AVG SPEED',
                          '${trip.avgSpeedKmh.toStringAsFixed(1)} km/h',
                          Icons.speed_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Carbon Savings highlight
              if (trip.carbonSavedKg > 0.0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.paleSage.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.mintAccent),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco_rounded,
                          color: AppColors.forestGreen, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Carbon Avoided vs. Petrol Car',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.forestGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'You saved ${trip.carbonSavedKg.toStringAsFixed(2)} kg CO₂ on this trip!',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 28),

              // Actions: Save vs Discard
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.borderGray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        ref.read(trackingProvider.notifier).reset();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Discard',
                        style: TextStyle(
                          color: AppColors.charcoal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        await ref
                            .read(tripHistoryProvider.notifier)
                            .saveTrip(trip);
                        ref.read(trackingProvider.notifier).reset();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Trip saved successfully to history!'),
                              backgroundColor: AppColors.forestGreen,
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text(
                        'Save to Logbook',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(
    String label,
    String value,
    IconData icon, {
    bool isHighlight = false,
    Color? highlightColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.warmGray),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isHighlight ? highlightColor : AppColors.charcoal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

