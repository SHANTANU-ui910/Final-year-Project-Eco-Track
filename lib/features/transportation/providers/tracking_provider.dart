import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/location_point.dart';
import '../models/trip_model.dart';
import '../models/vehicle_type.dart';
import '../services/activity_detection_engine.dart';
import '../services/location_service.dart';

enum TrackingStatus {
  idle,
  tracking,
  paused,
  stopped,
}

class TrackingState {
  final TrackingStatus status;
  final VehicleType vehicleType;
  final bool isAutoDetectEnabled;
  final double autoConfidence;
  final DateTime? startTime;
  final Duration elapsedDuration;
  final double currentSpeedKmh;
  final double distanceKm;
  final double co2EmissionsKg;
  final double carbonSavedKg;
  final double maxSpeedKmh;
  final List<LocationPoint> routePoints;
  final LocationPoint? lastPoint;
  final String? errorMessage;

  const TrackingState({
    this.status = TrackingStatus.idle,
    this.vehicleType = VehicleType.walking,
    this.isAutoDetectEnabled = true,
    this.autoConfidence = 0.92,
    this.startTime,
    this.elapsedDuration = Duration.zero,
    this.currentSpeedKmh = 0.0,
    this.distanceKm = 0.0,
    this.co2EmissionsKg = 0.0,
    this.carbonSavedKg = 0.0,
    this.maxSpeedKmh = 0.0,
    this.routePoints = const [],
    this.lastPoint,
    this.errorMessage,
  });

  double get avgSpeedKmh {
    if (elapsedDuration.inSeconds == 0) return 0.0;
    final hours = elapsedDuration.inSeconds / 3600.0;
    return distanceKm / hours;
  }

  TrackingState copyWith({
    TrackingStatus? status,
    VehicleType? vehicleType,
    bool? isAutoDetectEnabled,
    double? autoConfidence,
    DateTime? startTime,
    Duration? elapsedDuration,
    double? currentSpeedKmh,
    double? distanceKm,
    double? co2EmissionsKg,
    double? carbonSavedKg,
    double? maxSpeedKmh,
    List<LocationPoint>? routePoints,
    LocationPoint? lastPoint,
    String? errorMessage,
  }) {
    return TrackingState(
      status: status ?? this.status,
      vehicleType: vehicleType ?? this.vehicleType,
      isAutoDetectEnabled: isAutoDetectEnabled ?? this.isAutoDetectEnabled,
      autoConfidence: autoConfidence ?? this.autoConfidence,
      startTime: startTime ?? this.startTime,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      distanceKm: distanceKm ?? this.distanceKm,
      co2EmissionsKg: co2EmissionsKg ?? this.co2EmissionsKg,
      carbonSavedKg: carbonSavedKg ?? this.carbonSavedKg,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      routePoints: routePoints ?? this.routePoints,
      lastPoint: lastPoint ?? this.lastPoint,
      errorMessage: errorMessage,
    );
  }
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  final LocationService _locationService;
  final ActivityDetectionEngine _detectionEngine = ActivityDetectionEngine();
  StreamSubscription<LocationPoint>? _locationSubscription;
  Timer? _timer;

  TrackingNotifier(this._locationService) : super(const TrackingState());

  void setVehicleType(VehicleType type) {
    state = state.copyWith(
      vehicleType: type,
      isAutoDetectEnabled: false,
    );
  }

  void toggleAutoDetect(bool enable) {
    state = state.copyWith(isAutoDetectEnabled: enable);
  }

  Future<bool> startTrip({VehicleType? explicitType, bool autoDetect = true}) async {
    final hasPermission = await _locationService.checkAndRequestPermission();
    if (!hasPermission) {
      state = state.copyWith(
        errorMessage: 'GPS Location permissions are required for automatic tracking.',
      );
      return false;
    }

    _detectionEngine.reset();

    state = TrackingState(
      status: TrackingStatus.tracking,
      vehicleType: explicitType ?? VehicleType.walking,
      isAutoDetectEnabled: autoDetect,
      autoConfidence: 0.95,
      startTime: DateTime.now(),
      elapsedDuration: Duration.zero,
      distanceKm: 0.0,
      co2EmissionsKg: 0.0,
      carbonSavedKg: 0.0,
      currentSpeedKmh: 0.0,
      maxSpeedKmh: 0.0,
      routePoints: [],
    );

    _startDurationTimer();
    _subscribeToLocation();
    return true;
  }

  void pauseTrip() {
    if (state.status != TrackingStatus.tracking) return;
    _timer?.cancel();
    _locationSubscription?.pause();
    state = state.copyWith(
      status: TrackingStatus.paused,
      currentSpeedKmh: 0.0,
    );
  }

  void resumeTrip() {
    if (state.status != TrackingStatus.paused) return;
    _startDurationTimer();
    _locationSubscription?.resume();
    state = state.copyWith(status: TrackingStatus.tracking);
  }

  TripModel stopTrip() {
    _timer?.cancel();
    _locationSubscription?.cancel();

    final endTime = DateTime.now();
    final trip = TripModel(
      id: const Uuid().v4(),
      vehicleType: state.vehicleType,
      startTime: state.startTime ?? endTime,
      endTime: endTime,
      distanceKm: state.distanceKm,
      co2EmissionsKg: state.co2EmissionsKg,
      carbonSavedKg: state.carbonSavedKg,
      avgSpeedKmh: state.avgSpeedKmh,
      maxSpeedKmh: state.maxSpeedKmh,
      routePoints: List.from(state.routePoints),
    );

    state = state.copyWith(status: TrackingStatus.stopped);
    return trip;
  }

  void reset() {
    _timer?.cancel();
    _locationSubscription?.cancel();
    _detectionEngine.reset();
    state = const TrackingState();
  }

  void _startDurationTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status == TrackingStatus.tracking) {
        state = state.copyWith(
          elapsedDuration: state.elapsedDuration + const Duration(seconds: 1),
        );
      }
    });
  }

  void _subscribeToLocation() {
    _locationSubscription?.cancel();
    _locationSubscription = _locationService.getPositionStream().listen(
      (LocationPoint newPoint) {
        if (state.status != TrackingStatus.tracking) return;

        // Auto-detect transit mode dynamically if enabled
        VehicleType currentType = state.vehicleType;
        if (state.isAutoDetectEnabled) {
          currentType = _detectionEngine.addPointAndDetectMode(
            currentSpeedKmh: newPoint.speedKmh,
            timestamp: newPoint.timestamp,
          );
        }

        double addedDistKm = 0.0;
        if (state.lastPoint != null) {
          addedDistKm = LocationService.calculateDistanceKm(
            startLat: state.lastPoint!.latitude,
            startLng: state.lastPoint!.longitude,
            endLat: newPoint.latitude,
            endLng: newPoint.longitude,
          );

          if (addedDistKm < 0.002 || newPoint.speedKmh > 260) {
            addedDistKm = 0.0;
          }
        }

        final updatedDistance = state.distanceKm + addedDistKm;
        final updatedEmissions = updatedDistance * currentType.emissionFactor;
        final baselineEmissions = updatedDistance * 0.171;
        final updatedSaved = (baselineEmissions - updatedEmissions) > 0
            ? (baselineEmissions - updatedEmissions)
            : 0.0;

        final newMaxSpeed = newPoint.speedKmh > state.maxSpeedKmh
            ? newPoint.speedKmh
            : state.maxSpeedKmh;

        final updatedPoints = List<LocationPoint>.from(state.routePoints)
          ..add(newPoint);

        state = state.copyWith(
          vehicleType: currentType,
          currentSpeedKmh: newPoint.speedKmh,
          maxSpeedKmh: newMaxSpeed,
          distanceKm: updatedDistance,
          co2EmissionsKg: updatedEmissions,
          carbonSavedKg: updatedSaved,
          routePoints: updatedPoints,
          lastPoint: newPoint,
        );
      },
      onError: (err) {
        state = state.copyWith(errorMessage: err.toString());
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(service.dispose);
  return service;
});

final trackingProvider =
    StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return TrackingNotifier(locationService);
});
