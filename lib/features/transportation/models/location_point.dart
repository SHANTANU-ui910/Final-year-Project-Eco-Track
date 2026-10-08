class LocationPoint {
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double altitude;
  final DateTime timestamp;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.altitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'speedKmh': speedKmh,
      'altitude': altitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      speedKmh: (map['speedKmh'] as num).toDouble(),
      altitude: (map['altitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

