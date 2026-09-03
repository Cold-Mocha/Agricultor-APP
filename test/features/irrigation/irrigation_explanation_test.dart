import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_explanation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('explanation is deterministic and only uses calculation facts', () {
    const result = IrrigationEstimateResult(
      appliedVolumeMl: 12000,
      recommendedVolumeMl: 25000,
      recommendedDurationSeconds: 750,
      algorithmVersion: 2,
      ruleId: 'rule-1',
      ruleVersion: 3,
      warnings: ['weather_unavailable', 'adjustment_clamped'],
      explanationFacts: {
        'plant_count': 20,
        'base_ml_per_plant': 1000,
        'bounded_adjustment_bp': 12500,
      },
    );

    expect(
      IrrigationExplanation.short(result),
      '25.0 L durante 13 min: 20 plantas × 1.0 L, ajuste 125%.',
    );
    expect(IrrigationExplanation.warnings(result), [
      'Sin datos meteorológicos: se usó el ajuste base aprobado.',
      'El ajuste fue limitado al rango seguro de la regla aprobada.',
    ]);
  });
}
