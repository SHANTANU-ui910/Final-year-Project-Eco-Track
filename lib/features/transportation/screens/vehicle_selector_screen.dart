import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/vehicle_type.dart';

class VehicleSelectorSheet extends ConsumerStatefulWidget {
  final ValueChanged<VehicleType> onVehicleSelected;

  const VehicleSelectorSheet({
    super.key,
    required this.onVehicleSelected,
  });

  static Future<VehicleType?> show(BuildContext context) {
    return showModalBottomSheet<VehicleType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VehicleSelectorSheet(
        onVehicleSelected: (type) => Navigator.of(context).pop(type),
      ),
    );
  }

  @override
  ConsumerState<VehicleSelectorSheet> createState() =>
      _VehicleSelectorSheetState();
}

class _VehicleSelectorSheetState extends ConsumerState<VehicleSelectorSheet> {
  VehicleType _selected = VehicleType.petrolCar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 32),
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title & Description
          Text('Select Transit Mode', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 6),
          Text(
            'Choose your vehicle or activity to calculate real-time emissions accurately.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warmGray),
          ),
          const SizedBox(height: 20),

          // Vehicle List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: VehicleType.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final type = VehicleType.values[index];
                final isSelected = type == _selected;

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selected = type;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.paleSage.withValues(alpha: 0.5)
                          : AppColors.offWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.forestGreen
                            : AppColors.borderGray.withValues(alpha: 0.5),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.forestGreen
                                : AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            type.iconData,
                            size: 22,
                            color: isSelected
                                ? Colors.white
                                : AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.displayName,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                type.isZeroEmission
                                    ? 'Zero Emission • 0.00 kg CO₂e / km'
                                    : '${type.emissionFactor.toStringAsFixed(3)} kg CO₂e / km',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: type.isZeroEmission
                                      ? AppColors.sage
                                      : AppColors.warmGray,
                                  fontWeight: type.isZeroEmission
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.forestGreen,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => widget.onVehicleSelected(_selected),
              child: Text(
                'Start Tracking with ${_selected.shortLabel}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

