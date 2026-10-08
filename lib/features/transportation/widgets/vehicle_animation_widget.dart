import 'package:flutter/material.dart';
import '../models/vehicle_type.dart';
import 'kinematic_engine/design_tokens.dart';
import 'kinematic_engine/vehicle_animation_card.dart';

/// Adapter widget that connects the application's [VehicleType] state to the
/// luxury [VehicleAnimationCard] Kinematic Engine.
class VehicleAnimationWidget extends StatelessWidget {
  final double currentSpeedKmh;
  final VehicleType vehicleType;
  final bool isMoving;
  final VoidCallback? onTap;

  const VehicleAnimationWidget({
    super.key,
    required this.currentSpeedKmh,
    required this.vehicleType,
    required this.isMoving,
    this.onTap,
  });

  /// Maps domain [VehicleType] to one of the 4 kinematic showcase modules:
  /// Scooty, Car, Bike, Bus.
  VehicleModule _mapVehicleTypeToModule(VehicleType type) {
    switch (type) {
      case VehicleType.scooter:
      case VehicleType.electricScooter:
        return VehicleModule.scooty;
      case VehicleType.motorcycle:
      case VehicleType.bicycle:
        return VehicleModule.bike;
      case VehicleType.petrolCar:
      case VehicleType.dieselCar:
      case VehicleType.electricVehicle:
        return VehicleModule.car;
      case VehicleType.bus:
      case VehicleType.train:
      case VehicleType.walking:
        return VehicleModule.bus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VehicleAnimationCard(
      module: _mapVehicleTypeToModule(vehicleType),
      currentSpeedKmh: currentSpeedKmh,
      isMoving: isMoving,
      onTap: onTap,
    );
  }
}
