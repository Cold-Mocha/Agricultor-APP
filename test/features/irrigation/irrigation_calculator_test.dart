import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_rule_set.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const input = IrrigationCalculationInput(
    plantCount: 100,
    flowMilliLitersPerHourPerPlant: 2000,
    requestedMinutes: 30,
  );

  test('without an approved rule calculation is unavailable', () {
    final result = IrrigationCalculator.calculate(input);
    expect(result, isA<IrrigationUnavailable>());
    expect((result as IrrigationUnavailable).code, 'crop_rule_unavailable');
  });

  test('scaled integer engine is deterministic for a test-only rule', () {
    const rule = IrrigationRuleSet(
      id: 'synthetic-test-only',
      cropId: 'test-crop',
      soilTypeCode: 'test-soil',
      version: 1,
      soilMultiplierPermille: 1000,
      efficiencyPermille: 1000,
      minimumDurationMinutes: 1,
      maximumDurationMinutes: 120,
      sourceTitle: 'Synthetic test fixture',
      sourceReference: 'not-for-production',
    );
    for (var vector = 0; vector < 20; vector++) {
      final first = IrrigationCalculator.calculate(
        input,
        rule: rule,
      ) as IrrigationEstimateResult;
      final second = IrrigationCalculator.calculate(
        input,
        rule: rule,
      ) as IrrigationEstimateResult;
      expect(second.estimatedLitersMilli, first.estimatedLitersMilli);
      expect(second.recommendedMinutes, first.recommendedMinutes);
    }
  });
}
