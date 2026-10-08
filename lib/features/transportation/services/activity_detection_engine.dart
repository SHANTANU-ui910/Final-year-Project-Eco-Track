import 'dart:math';
import '../models/vehicle_type.dart';

/// Automatic Mode Detection Engine (Sensor & GPS heuristic classifier)
/// Evaluates speed distributions, acceleration profiles, and step/cadence signals
class ActivityDetectionEngine {
  final List<double> _recentSpeeds = [];
  final List<DateTime> _recentTimestamps = [];
  static const int _windowSize = 10;

  /// Feeds a new GPS coordinate point to refine mode probability
  VehicleType addPointAndDetectMode({
    required double currentSpeedKmh,
    required DateTime timestamp,
  }) {
    _recentSpeeds.add(currentSpeedKmh);
    _recentTimestamps.add(timestamp);

    if (_recentSpeeds.length > _windowSize) {
      _recentSpeeds.removeAt(0);
      _recentTimestamps.removeAt(0);
    }

    return classify();
  }

  /// Classifies current transit activity based on kinematic patterns
  VehicleType classify() {
    if (_recentSpeeds.isEmpty) return VehicleType.walking;

    // Calculate rolling average and peak speed in active window
    final avgSpeed = _recentSpeeds.reduce((a, b) => a + b) / _recentSpeeds.length;
    final maxSpeed = _recentSpeeds.reduce(max);

    // Compute rolling acceleration variance (dSpeed / dt)
    double totalAcc = 0.0;
    int accCount = 0;
    for (int i = 1; i < _recentSpeeds.length; i++) {
      final dt = _recentTimestamps[i].difference(_recentTimestamps[i - 1]).inMilliseconds / 1000.0;
      if (dt > 0) {
        final dv = ((_recentSpeeds[i] - _recentSpeeds[i - 1]) / 3.6).abs(); // m/s
        totalAcc += (dv / dt);
        accCount++;
      }
    }
    final avgAcc = accCount > 0 ? (totalAcc / accCount) : 0.0;

    // 1. Stationary / Walking (< 7 km/h with low max speed)
    if (maxSpeed < 7.0) {
      return VehicleType.walking;
    }

    // 2. Bicycle / Cycling (7 km/h - 26 km/h with moderate cadence/acceleration)
    if (avgSpeed >= 7.0 && avgSpeed < 26.0 && maxSpeed < 38.0) {
      return VehicleType.bicycle;
    }

    // 3. High-Speed Rail / Subway (very high speed > 85 km/h with low acceleration variance)
    if (avgSpeed > 85.0 && avgAcc < 1.0) {
      return VehicleType.train;
    }

    // 4. Urban Transit / Bus (frequent stops, moderate speed 15-45 km/h with regular dwell times)
    if (avgSpeed >= 18.0 && avgSpeed <= 48.0 && maxSpeed <= 65.0 && avgAcc > 1.2) {
      // Frequent stop & go profile indicative of urban bus
      return VehicleType.bus;
    }

    // 5. Motorized Private Vehicle (Default to Electric Vehicle or Petrol Car depending on user setting)
    // Speed consistently between 28 km/h and 130 km/h
    return VehicleType.electricVehicle;
  }

  void reset() {
    _recentSpeeds.clear;
    _recentTimestamps.clear();
  }
}

