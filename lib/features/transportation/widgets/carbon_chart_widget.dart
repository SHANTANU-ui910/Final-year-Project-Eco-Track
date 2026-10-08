import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CarbonChartWidget extends StatelessWidget {
  final double currentCarbonKg;
  final double maxExpectedKg;

  const CarbonChartWidget({
    super.key,
    required this.currentCarbonKg,
    this.maxExpectedKg = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentCarbonKg / maxExpectedKg).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CARBON ACCUMULATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.warmGray,
                ),
              ),
              Text(
                '${currentCarbonKg.toStringAsFixed(2)} kg CO₂e',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.7
                    ? AppColors.alertRed
                    : progress > 0.4
                        ? AppColors.warningAmber
                        : AppColors.sage,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '0 kg',
                style: TextStyle(fontSize: 10, color: AppColors.warmGray),
              ),
              Text(
                'Cap Target: ${maxExpectedKg.toStringAsFixed(0)} kg',
                style: const TextStyle(fontSize: 10, color: AppColors.warmGray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

