import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TripControlsWidget extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onPauseResume;
  final VoidCallback onStop;

  const TripControlsWidget({
    super.key,
    required this.isPaused,
    required this.onPauseResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause / Resume Action
        SizedBox(
          width: 72,
          height: 72,
          child: FloatingActionButton(
            heroTag: 'pause_resume_btn',
            elevation: 3,
            backgroundColor: isPaused ? AppColors.sage : AppColors.pureWhite,
            foregroundColor: isPaused ? Colors.white : AppColors.charcoal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
              side: const BorderSide(color: AppColors.borderGray, width: 1.2),
            ),
            onPressed: onPauseResume,
            child: Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              size: 34,
            ),
          ),
        ),
        const SizedBox(width: 28),

        // Stop Trip Action (End & Save)
        SizedBox(
          width: 72,
          height: 72,
          child: FloatingActionButton(
            heroTag: 'stop_trip_btn',
            elevation: 4,
            backgroundColor: AppColors.alertRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36),
            ),
            onPressed: onStop,
            child: const Icon(
              Icons.stop_rounded,
              size: 36,
            ),
          ),
        ),
      ],
    );
  }
}

