import 'vehicle_type.dart';
import 'location_point.dart';

class TripModel {
  final String id;
  final VehicleType vehicleType;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceKm;
  final double co2EmissionsKg;
  final double carbonSavedKg;
  final double avgSpeedKmh;
  final double maxSpeedKmh;
  final List<LocationPoint> routePoints;
  final bool isSynced;

  const TripModel({
    required this.id,
    required this.vehicleType,
    required this.startTime,
    required this.endTime,
    required this.distanceKm,
    required this.co2EmissionsKg,
    required this.carbonSavedKg,
    required this.avgSpeedKmh,
    required this.maxSpeedKmh,
    required this.routePoints,
    this.isSynced = false,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleType': vehicleType.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'distanceKm': distanceKm,
      'co2EmissionsKg': co2EmissionsKg,
      'carbonSavedKg': carbonSavedKg,
      'avgSpeedKmh': avgSpeedKmh,
      'maxSpeedKmh': maxSpeedKmh,
      'routePoints': routePoints.map((p) => p.toMap()).toList(),
      'isSynced': isSynced,
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] as String,
      vehicleType: VehicleType.values.firstWhere(
        (e) => e.name == map['vehicleType'],
        orElse: () => VehicleType.petrolCar,
      ),
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      distanceKm: (map['distanceKm'] as num).toDouble(),
      co2EmissionsKg: (map['co2EmissionsKg'] as num).toDouble(),
      carbonSavedKg: (map['carbonSavedKg'] as num?)?.toDouble() ?? 0.0,
      avgSpeedKmh: (map['avgSpeedKmh'] as num).toDouble(),
      maxSpeedKmh: (map['maxSpeedKmh'] as num?)?.toDouble() ?? 0.0,
      routePoints: (map['routePoints'] as List<dynamic>?)
              ?.map((p) => LocationPoint.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
      isSynced: (map['isSynced'] as bool?) ?? false,
    );
  }
}

