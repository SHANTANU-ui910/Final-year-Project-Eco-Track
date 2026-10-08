import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LiveMetricsWidget extends StatelessWidget {
  final double speedKmh;
  final double distanceKm;
  final double co2EmissionsKg;
  final Duration elapsedDuration;

  const LiveMetricsWidget({
    super.key,
    required this.speedKmh,
    required this.distanceKm,
    required this.co2EmissionsKg,
    required this.elapsedDuration,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          // Primary Hero Metric: Speed
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: speedKmh),
                duration: const Duration(milliseconds: 350),
                builder: (context, val, child) {
                  return Text(
                    val.toStringAsFixed(1),
                    style: AppTextStyles.metricHuge.copyWith(
                      color: AppColors.forestGreen,
                      fontSize: 48,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                'km/h',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.warmGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 18),

          // Secondary Tri-Panel: Distance, CO2e, Duration
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'DISTANCE',
                  valueWidget: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: distanceKm),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, val, child) {
                      return Text(
                        val < 10
                            ? val.toStringAsFixed(2)
                            : val.toStringAsFixed(1),
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.charcoal,
                        ),
                      );
                    },
                  ),
                  unit: 'km',
                ),
              ),
              Container(
                height: 38,
                width: 1,
                color: AppColors.borderGray,
              ),
              Expanded(
                child: _buildMetricTile(
                  label: 'CARBON',
                  valueWidget: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: co2EmissionsKg),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, val, child) {
                      return Text(
                        val.toStringAsFixed(2),
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: val > 0.0
                              ? AppColors.alertRed.withValues(alpha: 0.9)
                              : AppColors.sage,
                        ),
                      );
                    },
                  ),
                  unit: 'kg CO₂e',
                ),
              ),
              Container(
                height: 38,
                width: 1,
                color: AppColors.borderGray,
              ),
              Expanded(
                child: _buildMetricTile(
                  label: 'DURATION',
                  valueWidget: Text(
                    _formatDuration(elapsedDuration),
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.charcoal,
                    ),
                  ),
                  unit: 'time',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required Widget valueWidget,
    required String unit,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        valueWidget,
        const SizedBox(height: 2),
        Text(
          unit,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.warmGray,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

