import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/vehicle_type.dart';
import '../providers/trip_history_provider.dart';
import '../widgets/trip_card_widget.dart';
import 'trip_detail_screen.dart';

class TripHistoryScreen extends ConsumerStatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  ConsumerState<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends ConsumerState<TripHistoryScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripHistoryProvider);
    final historyNotifier = ref.read(tripHistoryProvider.notifier);

    final filteredTrips = trips.where((trip) {
      if (_selectedFilter == 'Zero Emission') {
        return trip.vehicleType.isZeroEmission;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Trip Logbook'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Aggregated Metrics Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.forestGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderMetric(
                  'TOTAL DISTANCE',
                  '${historyNotifier.totalDistanceKm.toStringAsFixed(1)} km',
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                _buildHeaderMetric(
                  'TOTAL CARBON',
                  '${historyNotifier.totalCo2EmissionsKg.toStringAsFixed(2)} kg',
                ),
                Container(
                  width: 1,
                  height: 32,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                _buildHeaderMetric(
                  'CARBON SAVED',
                  '${historyNotifier.totalCarbonSavedKg.toStringAsFixed(2)} kg',
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildChip('All'),
                const SizedBox(width: 8),
                _buildChip('Zero Emission'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Trips List
          Expanded(
            child: filteredTrips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 54,
                          color: AppColors.warmGray.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No trips recorded yet',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.warmGray,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start tracking your commute to see your carbon log.',
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
                      final trip = filteredTrips[index];
                      return TripCardWidget(
                        trip: trip,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  TripDetailScreen(trip: trip),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: AppColors.forestGreen,
      backgroundColor: AppColors.pureWhite,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.charcoal,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.forestGreen : AppColors.borderGray,
        ),
      ),
    );
  }

  Widget _buildHeaderMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

