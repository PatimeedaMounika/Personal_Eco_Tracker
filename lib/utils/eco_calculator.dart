double calculateCarbonSavings({
  required double carKm,
  required double emissionPerKm,
}) {
  if (carKm < 0 || emissionPerKm < 0) {
    throw ArgumentError('Values cannot be negative');
  }

  return carKm * emissionPerKm;
}
