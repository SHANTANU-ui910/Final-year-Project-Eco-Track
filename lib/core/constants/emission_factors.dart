/// Standardized emission factors for various transit modes
/// Expressed in kg CO2 equivalent per passenger-kilometer (kg CO2e / km)
/// Sourced from standard environmental protection agencies and DEFRA datasets
class EmissionFactors {
  EmissionFactors._();

  // Factors in kg CO2e per km
  static const double petrolCar = 0.171;
  static const double dieselCar = 0.147;
  static const double hybridCar = 0.105;
  static const double electricVehicle = 0.053;
  static const double motorcycle = 0.113;
  static const double petrolScooter = 0.082; // Petrol Scooty / Moped (e.g. Activa, Jupiter ~0.082 kg CO2e/km)
  static const double electricScooter = 0.025; // Electric Scooty (e.g. Ather, Ola EV ~0.025 kg CO2e/km)
  static const double bus = 0.089;
  static const double train = 0.041;
  static const double subway = 0.035;
  static const double bicycle = 0.000;
  static const double walking = 0.000;

  /// Calculate total emissions given vehicle factor and distance in km
  static double calculateEmissions({
    required double emissionFactor,
    required double distanceKm,
  }) {
    if (distanceKm <= 0 || emissionFactor <= 0) return 0.0;
    return distanceKm * emissionFactor;
  }

  /// Calculates potential carbon saved compared to average single-occupancy petrol vehicle
  static double calculateSavings({
    required double vehicleFactor,
    required double distanceKm,
  }) {
    if (distanceKm <= 0) return 0.0;
    final petrolBaseline = distanceKm * petrolCar;
    final actual = distanceKm * vehicleFactor;
    final saved = petrolBaseline - actual;
    return saved > 0 ? saved : 0.0;
  }
}
