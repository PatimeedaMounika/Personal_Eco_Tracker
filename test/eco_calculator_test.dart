import 'package:flutter_test/flutter_test.dart';
import 'package:personal_eco_tracker/utils/eco_calculator.dart';

void main() {
  group('Carbon calculation unit tests', () {
    test('Calculates emissions correctly', () {
      final result = calculateCarbonSavings(carKm: 100, emissionPerKm: 0.2);

      expect(result, 20.0);
    });

    test('Returns zero for zero distance', () {
      final result = calculateCarbonSavings(carKm: 0, emissionPerKm: 0.2);

      expect(result, 0.0);
    });

    test('Throws error for negative distance', () {
      expect(
        () => calculateCarbonSavings(carKm: -10, emissionPerKm: 0.2),
        throwsArgumentError,
      );
    });
  });
}
