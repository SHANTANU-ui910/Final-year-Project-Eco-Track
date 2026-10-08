import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/location_point.dart';
import '../models/trip_model.dart';
import '../models/vehicle_type.dart';
import '../services/activity_detection_engine.dart';
import '../services/location_service.dart';
import 'tracking_provider.dart';
import 'trip_history_provider.dart';

enum PassiveTrackingState {
  standby,     // Stationary, awaiting movement
  activeTrip,  // Automatically tracking ongoing commute
}

class AutoTripState {
  final PassiveTrackingState state;
  final VehicleType currentMode;
  final double currentSpeedKmh;
  final double tripDistanceKm;
  final double tripCo2Kg;
  final double carbonSavedKg;
  final Duration tripDuration;
  final List<LocationPoint> activeRoutePoints;
  final String statusDescription;

  const AutoTripState({
    this.state = PassiveTrackingState.standby,
    this.currentMode = VehicleType.walking,
    this.currentSpeedKmh = 0.0,
    this.tripDistanceKm = 0.0,
    this.tripCo2Kg = 0.0,
    this.carbonSavedKg = 0.0,
    this.tripDuration = Duration.zero,
    this.activeRoutePoints = const [],
    this.statusDescription = 'Background Service: Stationary (0.0 km/h)',
  });

  AutoTripState copyWith({
    PassiveTrackingState? state,
    VehicleType? currentMode,
    double? currentSpeedKmh,
    double? tripDistanceKm,
    double? tripCo2Kg,
    double? carbonSavedKg,
    Duration? tripDuration,
    List<LocationPoint>? activeRoutePoints,
    String? statusDescription,
  }) {
    return AutoTripState(
      state: state ?? this.state,
      currentMode: currentMode ?? this.currentMode,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      tripDistanceKm: tripDistanceKm ?? this.tripDistanceKm,
      tripCo2Kg: tripCo2Kg ?? this.tripCo2Kg,
      carbonSavedKg: carbonSavedKg ?? this.carbonSavedKg,
      tripDuration: tripDuration ?? this.tripDuration,
      activeRoutePoints: activeRoutePoints ?? this.activeRoutePoints,
      statusDescription: statusDescription ?? this.statusDescription,
    );
  }
}

class BackgroundMobilityNotifier extends StateNotifier<AutoTripState> {
  final LocationService _locationService;
  final ActivityDetectionEngine _detectionEngine = ActivityDetectionEngine();
  final Ref _ref;

  StreamSubscription<LocationPoint>? _gpsStream;
  Timer? _tripDurationTimer;
  LocationPoint? _lastPoint;
  DateTime? _lastMovedTimestamp;
  DateTime? _tripStartTime;

  // Zero-Velocity Stationary Filter Thresholds
  static const double _minMovingSpeedKmh = 2.8; // Anything < 2.8 km/h is treated as true 0.0 km/h
  static const double _minDistanceMeters = 4.5; // GPS drift threshold
  static const int _stationarySecondsToAutoEnd = 90; // Auto-end trip after 90s idle

  BackgroundMobilityNotifier(this._locationService, this._ref)
      : super(const AutoTripState()) {
    _startContinuousBackgroundEngine();
  }

  void _startContinuousBackgroundEngine() async {
    final granted = await _locationService.checkAndRequestPermission();
    if (!granted) {
      state = state.copyWith(statusDescription: 'Location permission required for background engine');
      return;
    }

    _gpsStream = _locationService.getPositionStream().listen(_processIncomingGpsTelemetry);
  }

  void _processIncomingGpsTelemetry(LocationPoint point) {
    double cleanSpeed = point.speedKmh;

    // Strict zero-speed snap filter
    if (cleanSpeed < _minMovingSpeedKmh) {
      cleanSpeed = 0.0;
    }

    // Measure delta from previous point
    double deltaMeters = 0.0;
    if (_lastPoint != null) {
      final dKm = LocationService.calculateDistanceKm(
        startLat: _lastPoint!.latitude,
        startLng: _lastPoint!.longitude,
        endLat: point.latitude,
        endLng: point.longitude,
      );
      deltaMeters = dKm * 1000.0;
    }

    // Filter out indoor satellite jitter (< 4.5 meters)
    if (deltaMeters < _minDistanceMeters) {
      cleanSpeed = 0.0;
    }

    final now = DateTime.now();

    // 1. IF MOVEMENT DETECTED: Automatic Trip Start or Accumulation
    if (cleanSpeed > 0.0) {
      _lastMovedTimestamp = now;

      if (state.state == PassiveTrackingState.standby) {
        // Auto-start trip without user clicking anything
        _tripStartTime = now;
        _startTimer();
        state = state.copyWith(
          state: PassiveTrackingState.activeTrip,
          tripDistanceKm: 0.0,
          tripCo2Kg: 0.0,
          tripDuration: Duration.zero,
          activeRoutePoints: [point],
        );
      }

      // Detect Mode
      final detectedMode = _detectionEngine.addPointAndDetectMode(
        currentSpeedKmh: cleanSpeed,
        timestamp: now,
      );

      final newDistKm = state.tripDistanceKm + (deltaMeters / 1000.0);
      final newCo2 = newDistKm * detectedMode.emissionFactor;
      final petrolBaseline = newDistKm * 0.171;
      final newSaved = max(0.0, petrolBaseline - newCo2);

      state = state.copyWith(
        currentSpeedKmh: cleanSpeed,
        currentMode: detectedMode,
        tripDistanceKm: newDistKm,
        tripCo2Kg: newCo2,
        carbonSavedKg: newSaved,
        activeRoutePoints: [...state.activeRoutePoints, point],
        statusDescription: 'Auto-tracking: ${detectedMode.displayName} (${cleanSpeed.toStringAsFixed(1)} km/h)',
      );
    } else {
      // 2. USER IS STANDING STILL: Strict 0.0 km/h
      state = state.copyWith(
        currentSpeedKmh: 0.0,
        statusDescription: state.state == PassiveTrackingState.activeTrip
            ? 'Stationary at red light / stop (0.0 km/h)'
            : 'Background Engine: Stationary (0.0 km/h)',
      );

      // Auto-save trip if stationary for > 90 seconds
      if (state.state == PassiveTrackingState.activeTrip && _lastMovedTimestamp != null) {
        final idleDuration = now.difference(_lastMovedTimestamp!).inSeconds;
        if (idleDuration >= _stationarySecondsToAutoEnd) {
          _autoFinalizeAndSaveTrip();
        }
      }
    }

    _lastPoint = point;
  }

  void _startTimer() {
    _tripDurationTimer?.cancel();
    _tripDurationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.state == PassiveTrackingState.activeTrip) {
        state = state.copyWith(
          tripDuration: state.tripDuration + const Duration(seconds: 1),
        );
      }
    });
  }

  void _autoFinalizeAndSaveTrip() {
    _tripDurationTimer?.cancel();

    // Only save trips with meaningful distance (> 100 meters)
    if (state.tripDistanceKm > 0.1) {
      final trip = TripModel(
        id: const Uuid().v4(),
        vehicleType: state.currentMode,
        startTime: _tripStartTime ?? DateTime.now().subtract(state.tripDuration),
        endTime: DateTime.now(),
        distanceKm: state.tripDistanceKm,
        co2EmissionsKg: state.tripCo2Kg,
        carbonSavedKg: state.carbonSavedKg,
        avgSpeedKmh: state.tripDuration.inSeconds > 0
            ? (state.tripDistanceKm / (state.tripDuration.inSeconds / 3600.0))
            : 0.0,
        maxSpeedKmh: 0.0,
        routePoints: List.from(state.activeRoutePoints),
      );

      _ref.read(tripHistoryProvider.notifier).saveTrip(trip);
    }

    // Reset back to background standby
    state = const AutoTripState(
      state: PassiveTrackingState.standby,
      statusDescription: 'Trip auto-saved to logbook. Standby active.',
    );
  }

  @override
  void dispose() {
    _gpsStream?.cancel();
    _tripDurationTimer?.cancel();
    super.dispose();
  }
}

final backgroundMobilityProvider =
    StateNotifierProvider<BackgroundMobilityNotifier, AutoTripState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return BackgroundMobilityNotifier(locationService, ref);
});

