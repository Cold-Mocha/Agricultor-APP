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
    final rule = IrrigationRuleSet(
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
      reviewer: 'Test reviewer',
      approvedAt: DateTime.utc(2026),
      approvedVectorCount: 20,
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
      expect(first.recommendedVolumeMl, 100000);
      expect(first.recommendedDurationSeconds, 1801);
      expect(first.appliedVolumeMl, 99990);
    }
  });

  test('release gate blocks a rule without reviewer and twenty vectors', () {
    const rule = IrrigationRuleSet(
      id: 'not-approved',
      cropId: 'crop',
      soilTypeCode: 'soil',
      version: 1,
      soilMultiplierPermille: 1000,
      efficiencyPermille: 1000,
      minimumDurationMinutes: 1,
      maximumDurationMinutes: 120,
      sourceTitle: 'Source',
      sourceReference: 'Ref',
    );
    expect(
      IrrigationCalculator.calculate(input, rule: rule),
      isA<IrrigationUnavailable>(),
    );
  });
}
