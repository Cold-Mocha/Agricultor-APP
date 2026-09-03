import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';

abstract final class IrrigationExplanation {
  static String short(IrrigationEstimateResult result) {
    final plants = _integer(result.explanationFacts, 'plant_count');
    final perPlant = _integer(result.explanationFacts, 'base_ml_per_plant');
    final adjustment = _integer(
      result.explanationFacts,
      'bounded_adjustment_bp',
    );
    final liters = (result.recommendedVolumeMl / 1000).toStringAsFixed(1);
    final minutes = result.recommendedMinutes;
    return '$liters L durante $minutes min: $plants plantas × '
        '${(perPlant / 1000).toStringAsFixed(1)} L, ajuste '
        '${(adjustment / 100).toStringAsFixed(0)}%.';
  }

  static List<String> warnings(IrrigationEstimateResult result) => [
    for (final code in result.warnings)
      switch (code) {
        'weather_unavailable' =>
          'Sin datos meteorológicos: se usó el ajuste base aprobado.',
        'adjustment_clamped' =>
          'El ajuste fue limitado al rango seguro de la regla aprobada.',
        _ => 'Advertencia de cálculo: $code.',
      },
  ];

  static int _integer(Map<String, Object?> facts, String key) {
    final value = facts[key];
    if (value is! int) throw StateError('irrigation_fact_invalid:$key');
    return value;
  }
}
