import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_model.dart';
import '../services/trip_storage_service.dart';

final tripStorageServiceProvider = Provider<TripStorageService>((ref) {
  return TripStorageService();
});

class TripHistoryNotifier extends StateNotifier<List<TripModel>> {
  final TripStorageService _storage;

  TripHistoryNotifier(this._storage) : super([]) {
    loadTrips();
  }

  void loadTrips() {
    state = _storage.getAllTrips();
  }

  Future<void> saveTrip(TripModel trip) async {
    await _storage.saveTrip(trip);
    loadTrips();
  }

  Future<void> deleteTrip(String tripId) async {
    await _storage.deleteTrip(tripId);
    loadTrips();
  }

  // Analytics Helpers
  double get totalDistanceKm =>
      state.fold(0.0, (prev, trip) => prev + trip.distanceKm);

  double get totalCo2EmissionsKg =>
      state.fold(0.0, (prev, trip) => prev + trip.co2EmissionsKg);

  double get totalCarbonSavedKg =>
      state.fold(0.0, (prev, trip) => prev + trip.carbonSavedKg);
}

final tripHistoryProvider =
    StateNotifierProvider<TripHistoryNotifier, List<TripModel>>((ref) {
  final storage = ref.watch(tripStorageServiceProvider);
  return TripHistoryNotifier(storage);
});

