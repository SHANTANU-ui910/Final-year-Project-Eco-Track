import 'package:hive_flutter/hive_flutter.dart';
import '../models/trip_model.dart';

class TripStorageService {
  static const String boxName = 'ecotra_trips_box';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(boxName);
  }

  Box<Map> get _box => Hive.box<Map>(boxName);

  Future<void> saveTrip(TripModel trip) async {
    await _box.put(trip.id, trip.toMap());
  }

  List<TripModel> getAllTrips() {
    final rawList = _box.values.toList();
    final trips = <TripModel>[];

    for (final item in rawList) {
      try {
        final Map<String, dynamic> converted =
            Map<String, dynamic>.from(item);
        trips.add(TripModel.fromMap(converted));
      } catch (e) {
        // Safe skip on corrupt items
      }
    }

    // Sort newest to oldest
    trips.sort((a, b) => b.startTime.compareTo(a.startTime));
    return trips;
  }

  Future<void> deleteTrip(String tripId) async {
    await _box.delete(tripId);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}

