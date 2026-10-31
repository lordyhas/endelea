import 'package:endelea/core/utils/units.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('weights', () {
    test('kg is displayed rounded to 0.5', () {
      expect(kgToDisplay(62.4, WeightUnit.kg), 62.5);
      expect(kgToDisplay(62.2, WeightUnit.kg), 62);
    });

    test('lb is displayed rounded to 1', () {
      expect(kgToDisplay(60, WeightUnit.lb), 132);
      expect(kgToDisplay(100, WeightUnit.lb), 220);
    });

    test('lb round trip keeps full precision', () {
      final kg = displayToKg(135, WeightUnit.lb);
      expect(kg, closeTo(61.235, 0.001));
      expect(kgToDisplay(kg, WeightUnit.lb), 135);
      expect(kgToDisplay(kg, WeightUnit.kg), 61);
    });

    test('kg is stored as entered', () {
      expect(displayToKg(62.5, WeightUnit.kg), 62.5);
    });

    test('default steps', () {
      expect(WeightUnit.kg.defaultStep, 2.5);
      expect(WeightUnit.lb.defaultStep, 5);
      expect(WeightUnit.fromKey('lb'), WeightUnit.lb);
      expect(WeightUnit.fromKey(null), WeightUnit.kg);
    });
  });

  group('formatting', () {
    test('decimals follow the locale', () {
      expect(formatDecimal(62.5, 'fr'), '62,5');
      expect(formatDecimal(62.5, 'en'), '62.5');
      expect(formatDecimal(60, 'fr'), '60');
      expect(formatWeight(60, WeightUnit.lb, 'en'), '132');
    });

    test('clock', () {
      expect(formatClock(const Duration(seconds: 90)), '1:30');
      expect(formatClock(const Duration(seconds: 5)), '0:05');
      expect(formatClock(const Duration(minutes: 62, seconds: 3)), '1:02:03');
      expect(formatClock(const Duration(seconds: -5)), '-0:05');
    });
  });
}
