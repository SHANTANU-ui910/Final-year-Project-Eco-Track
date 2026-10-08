import 'package:flutter/material.dart';
import '../../../core/constants/emission_factors.dart';

enum VehicleType {
  walking,
  bicycle,
  scooter, // Petrol Scooty / Moped (e.g., Activa, Jupiter)
  electricScooter, // EV Scooty (e.g., Ather, Ola)
  motorcycle, // Geared bike
  petrolCar,
  dieselCar,
  electricVehicle,
  bus,
  train,
}

extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.walking:
        return 'Walking';
      case VehicleType.bicycle:
        return 'Bicycle / Cycle';
      case VehicleType.scooter:
        return 'Scooter / Scooty (Petrol)';
      case VehicleType.electricScooter:
        return 'Electric Scooty (EV)';
      case VehicleType.motorcycle:
        return 'Motorcycle / Bike';
      case VehicleType.petrolCar:
        return 'Petrol Car';
      case VehicleType.dieselCar:
        return 'Diesel Car';
      case VehicleType.electricVehicle:
        return 'Electric Car (EV)';
      case VehicleType.bus:
        return 'Public Bus';
      case VehicleType.train:
        return 'Train / Metro';
    }
  }

  String get shortLabel {
    switch (this) {
      case VehicleType.walking:
        return 'Walk';
      case VehicleType.bicycle:
        return 'Cycle';
      case VehicleType.scooter:
        return 'Scooty';
      case VehicleType.electricScooter:
        return 'EV Scooty';
      case VehicleType.motorcycle:
        return 'Motorbike';
      case VehicleType.petrolCar:
        return 'Petrol Car';
      case VehicleType.dieselCar:
        return 'Diesel Car';
      case VehicleType.electricVehicle:
        return 'EV Car';
      case VehicleType.bus:
        return 'Bus';
      case VehicleType.train:
        return 'Train';
    }
  }

  double get emissionFactor {
    switch (this) {
      case VehicleType.walking:
        return EmissionFactors.walking; // 0.000
      case VehicleType.bicycle:
        return EmissionFactors.bicycle; // 0.000
      case VehicleType.scooter:
        return EmissionFactors.petrolScooter; // 0.082 kg CO2/km
      case VehicleType.electricScooter:
        return EmissionFactors.electricScooter; // 0.025 kg CO2/km
      case VehicleType.motorcycle:
        return EmissionFactors.motorcycle; // 0.113 kg CO2/km
      case VehicleType.petrolCar:
        return EmissionFactors.petrolCar; // 0.171 kg CO2/km
      case VehicleType.dieselCar:
        return EmissionFactors.dieselCar; // 0.147 kg CO2/km
      case VehicleType.electricVehicle:
        return EmissionFactors.electricVehicle; // 0.053 kg CO2/km
      case VehicleType.bus:
        return EmissionFactors.bus; // 0.089 kg CO2/km
      case VehicleType.train:
        return EmissionFactors.train; // 0.041 kg CO2/km
    }
  }

  IconData get iconData {
    switch (this) {
      case VehicleType.walking:
        return Icons.directions_walk_rounded;
      case VehicleType.bicycle:
        return Icons.directions_bike_rounded;
      case VehicleType.scooter:
      case VehicleType.electricScooter:
        return Icons.moped_rounded;
      case VehicleType.motorcycle:
        return Icons.two_wheeler_rounded;
      case VehicleType.petrolCar:
      case VehicleType.dieselCar:
        return Icons.directions_car_rounded;
      case VehicleType.electricVehicle:
        return Icons.electric_car_rounded;
      case VehicleType.bus:
        return Icons.directions_bus_rounded;
      case VehicleType.train:
        return Icons.train_rounded;
    }
  }

  bool get isZeroEmission => emissionFactor == 0.0;
}
