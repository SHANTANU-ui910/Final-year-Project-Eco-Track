/// Clean transit registry for the 4 core modes: Walking, Cycling, Car, and Bus.
class VehicleRegistryService {
  VehicleRegistryService._();

  static final Map<String, VehicleDetails> database = {
    'walking': const VehicleDetails(
      modelName: 'Walking',
      category: 'Pedestrian',
      fuelType: 'Zero Emission',
      engineDisplacement: 'Human Powered',
      mileageKmPerLitre: 0.0,
      emissionFactorKgCo2PerKm: 0.000,
      iconEmoji: '🚶',
      animType: 'walking',
    ),
    'cycling': const VehicleDetails(
      modelName: 'Cycling',
      category: 'Bicycle',
      fuelType: 'Zero Emission',
      engineDisplacement: 'Pedal Powered',
      mileageKmPerLitre: 0.0,
      emissionFactorKgCo2PerKm: 0.000,
      iconEmoji: '🚲',
      animType: 'cycling',
    ),
    'car': const VehicleDetails(
      modelName: 'Car',
      category: 'Passenger Car',
      fuelType: 'Petrol / Standard',
      engineDisplacement: 'Motor Vehicle',
      mileageKmPerLitre: 18.0,
      emissionFactorKgCo2PerKm: 0.171,
      iconEmoji: '🚗',
      animType: 'car',
    ),
    'bus': const VehicleDetails(
      modelName: 'Bus',
      category: 'Public Bus',
      fuelType: 'Shared Public Transit',
      engineDisplacement: 'Heavy Vehicle',
      mileageKmPerLitre: 4.5,
      emissionFactorKgCo2PerKm: 0.089,
      iconEmoji: '🚌',
      animType: 'bus',
    ),
  };

  static List<VehicleDetails> getAllModes() {
    return database.values.toList();
  }

  static VehicleDetails getMode(String key) {
    return database[key.toLowerCase()] ?? database['car']!;
  }
}

class VehicleDetails {
  final String modelName;
  final String category;
  final String fuelType;
  final String engineDisplacement;
  final double mileageKmPerLitre;
  final double emissionFactorKgCo2PerKm;
  final String registrationNumberPlaceholder;
  final String iconEmoji;
  final String animType;

  const VehicleDetails({
    required this.modelName,
    required this.category,
    required this.fuelType,
    required this.engineDisplacement,
    required this.mileageKmPerLitre,
    required this.emissionFactorKgCo2PerKm,
    this.registrationNumberPlaceholder = '',
    required this.iconEmoji,
    required this.animType,
  });
}
