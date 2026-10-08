import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/trip_model.dart';
import '../models/vehicle_type.dart';

class TripCardWidget extends StatelessWidget {
  final TripModel trip;
  final VoidCallback? onTap;

  const TripCardWidget({
    super.key,
    required this.trip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d • h:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Vehicle Mode Icon Indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: trip.vehicleType.isZeroEmission
                      ? AppColors.paleSage
                      : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  trip.vehicleType.iconData,
                  color: trip.vehicleType.isZeroEmission
                      ? AppColors.forestGreen
                      : AppColors.charcoal,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Title and Timestamps
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.vehicleType.displayName,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(trip.startTime),
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),

              // Distance & CO2 Summary
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${trip.distanceKm.toStringAsFixed(1)} km',
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: trip.vehicleType.isZeroEmission
                              ? AppColors.sage
                              : AppColors.alertRed,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${trip.co2EmissionsKg.toStringAsFixed(2)} kg CO₂',
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: trip.vehicleType.isZeroEmission
                              ? AppColors.sage
                              : AppColors.charcoal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

