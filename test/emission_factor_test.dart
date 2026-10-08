import 'package:flutter_test/flutter_test.dart';
import 'package:ecotra/core/constants/emission_factors.dart';

void main() {
  group('Emission Factors Calculation Tests', () {
    test('Zero emissions calculated for bicycle and walking', () {
      final bikeEmissions = EmissionFactors.calculateEmissions(
        emissionFactor: EmissionFactors.bicycle,
        distanceKm: 15.0,
      );
      expect(bikeEmissions, equals(0.0));

      final walkEmissions = EmissionFactors.calculateEmissions(
        emissionFactor: EmissionFactors.walking,
        distanceKm: 5.2,
      );
      expect(walkEmissions, equals(0.0));
    });

    test('Accurate calculation for petrol and EV', () {
      // 10 km on petrol car (0.171 kg/km) => 1.71 kg
      final petrolEmissions = EmissionFactors.calculateEmissions(
        emissionFactor: EmissionFactors.petrolCar,
        distanceKm: 10.0,
      );
      expect(petrolEmissions, closeTo(1.71, 0.001));

      // 10 km on EV (0.053 kg/km) => 0.53 kg
      final evEmissions = EmissionFactors.calculateEmissions(
        emissionFactor: EmissionFactors.electricVehicle,
        distanceKm: 10.0,
      );
      expect(evEmissions, closeTo(0.53, 0.001));
    });

    test('Savings calculation compares against petrol baseline correctly', () {
      // 10 km cycling vs petrol (1.71 kg saved)
      final cyclingSavings = EmissionFactors.calculateSavings(
        vehicleFactor: EmissionFactors.bicycle,
        distanceKm: 10.0,
      );
      expect(cyclingSavings, closeTo(1.71, 0.001));

      // 10 km EV vs petrol (1.71 - 0.53 = 1.18 kg saved)
      final evSavings = EmissionFactors.calculateSavings(
        vehicleFactor: EmissionFactors.electricVehicle,
        distanceKm: 10.0,
      );
      expect(evSavings, closeTo(1.18, 0.001));
    });
  });
}

