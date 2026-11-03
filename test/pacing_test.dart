import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/domain/rules/pacing_rules.dart';

void main() {
  group('PacingCalculator Tests', () {
    test('Calculates training paces and half marathon estimate accurately from 30 min 5k', () {
      // 30 minutes = 1800 seconds
      final result = PacingCalculator.calculateFrom5kTime(1800);

      // 5k pace should be 1800 / 5 = 360 s/km (6'00"/km)
      expect(result.fiveKPaceSecondsPerKm, 360);
      expect(result.testPaceFormatted, '6\'00"/km');

      // Easy pace should be 60-90s slower: 420-450 s/km (7'00" - 7'30"/km)
      expect(result.easyPaceMinSecondsPerKm, 420);
      expect(result.easyPaceMaxSecondsPerKm, 450);
      expect(result.easyPaceRangeFormatted, '7\'00"/km - 7\'30"/km');

      // Tempo pace should be 15-25s slower: 375-385 s/km
      expect(result.tempoPaceMinSecondsPerKm, 375);
      expect(result.tempoPaceMaxSecondsPerKm, 385);

      // Half marathon prediction:
      // Spec: "about 2:30-2:50 for a 30-32 min 5k"
      // Best case seconds in hours:
      final bestHours = result.halfMarathonBestCaseSeconds / 3600.0;
      final conservativeHours = result.halfMarathonConservativeSeconds / 3600.0;

      expect(bestHours, greaterThanOrEqualTo(2.4)); // ~ 2:25 - 2:35
      expect(conservativeHours, lessThanOrEqualTo(2.9)); // ~ 2:45 - 2:50
    });
  });
}

