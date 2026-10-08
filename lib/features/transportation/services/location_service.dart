import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/location_point.dart';

class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;

  /// Check and request location permissions gracefully
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get immediate current position
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return null;
    }
  }

  /// Subscribe to GPS stream with battery-optimized settings
  Stream<LocationPoint> getPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3, // meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((Position position) {
      // Speed in m/s converted to km/h, prevent negative speeds
      final speedKmh = position.speed > 0 ? (position.speed * 3.6) : 0.0;

      return LocationPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        speedKmh: speedKmh,
        altitude: position.altitude,
        timestamp: position.timestamp,
      );
    });
  }

  /// Accurate distance calculation between two coordinates using Haversine formula
  static double calculateDistanceKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    const double earthRadiusKm = 6371.0;

    final dLat = _degToRad(endLat - startLat);
    final dLng = _degToRad(endLng - startLng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(startLat)) *
            cos(_degToRad(endLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double degree) {
    return degree * (pi / 180.0);
  }

  void dispose() {
    _positionStreamSubscription?.cancel();
  }
}

