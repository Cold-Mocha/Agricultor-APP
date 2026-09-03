import 'package:agrocampo/features/irrigation/domain/irrigation_rule_set.dart';

final class IrrigationCalculationInput {
  const IrrigationCalculationInput({
    required this.plantCount,
    this.emitterCount,
    this.flowMlMin,
    this.performedDurationSeconds,
    this.weatherAdjustmentBp = 0,
    this.flowMilliLitersPerHourPerPlant,
    this.requestedMinutes,
  });

  final int plantCount;
  final int? emitterCount;
  final int? flowMlMin;
  final int? performedDurationSeconds;
  final int weatherAdjustmentBp;

  // Compatibility bridge for the original MVP input. New UI uses total ml/min.
  final int? flowMilliLitersPerHourPerPlant;
  final int? requestedMinutes;

  int get effectiveEmitterCount => emitterCount ?? plantCount;
  int get effectiveFlowMlMin =>
      flowMlMin ??
      ((plantCount * (flowMilliLitersPerHourPerPlant ?? 0) + 30) ~/ 60);
  int get effectiveDurationSeconds =>
      performedDurationSeconds ?? (requestedMinutes ?? 0) * 60;

  Map<String, Object?> toJson() => {
    'plant_count': plantCount,
    'emitter_count': effectiveEmitterCount,
    'flow_ml_min': effectiveFlowMlMin,
    'performed_duration_seconds': effectiveDurationSeconds,
    'weather_adjustment_bp': weatherAdjustmentBp,
  };
}

sealed class IrrigationCalculationResult {
  const IrrigationCalculationResult();
}

final class IrrigationUnavailable extends IrrigationCalculationResult {
  const IrrigationUnavailable(this.code, {this.fieldErrorCodes = const []});
  final String code;
  final List<String> fieldErrorCodes;
}

final class IrrigationEstimateResult extends IrrigationCalculationResult {
  const IrrigationEstimateResult({
    required this.appliedVolumeMl,
    required this.recommendedVolumeMl,
    required this.recommendedDurationSeconds,
    required this.algorithmVersion,
    required this.ruleId,
    required this.ruleVersion,
    required this.warnings,
    required this.explanationFacts,
  });

  final int appliedVolumeMl;
  final int recommendedVolumeMl;
  final int recommendedDurationSeconds;
  final int algorithmVersion;
  final String ruleId;
  final int ruleVersion;
  final List<String> warnings;
  final Map<String, Object?> explanationFacts;

  int get estimatedLitersMilli => recommendedVolumeMl;
  int get recommendedMinutes => (recommendedDurationSeconds + 59) ~/ 60;
}

abstract final class IrrigationCalculator {
  static const algorithmVersion = 2;

  static IrrigationCalculationResult calculate(
    IrrigationCalculationInput input, {
    IrrigationRuleSet? rule,
  }) {
    if (rule == null || !rule.releaseApproved) {
      return const IrrigationUnavailable('crop_rule_unavailable');
    }
    rule.validate();
    final errors = <String>[
      if (input.plantCount <= 0) 'plant_count_invalid',
      if (input.effectiveEmitterCount <= 0) 'emitter_count_invalid',
      if (input.effectiveFlowMlMin <= 0) 'flow_ml_min_invalid',
      if (input.effectiveDurationSeconds <= 0) 'performed_duration_invalid',
    ];
    if (errors.isNotEmpty) {
      return IrrigationUnavailable('invalid_input', fieldErrorCodes: errors);
    }
    final applied = _roundHalfUp(
      input.effectiveFlowMlMin * input.effectiveDurationSeconds,
      60,
    );
    final base = input.plantCount * rule.baseMlPerPlant;
    final soilAdjustmentBp = rule.soilMultiplierPermille * 10 - 10000;
    final rawAdjustment = 10000 + soilAdjustmentBp + input.weatherAdjustmentBp;
    final boundedAdjustment = rawAdjustment.clamp(
      rule.minimumAdjustmentBp,
      rule.maximumAdjustmentBp,
    );
    final recommended = _roundHalfUp(base * boundedAdjustment, 10000);
    final seconds = _ceilDivide(recommended * 60, input.effectiveFlowMlMin);
    return IrrigationEstimateResult(
      appliedVolumeMl: applied,
      recommendedVolumeMl: recommended,
      recommendedDurationSeconds: seconds,
      algorithmVersion: algorithmVersion,
      ruleId: rule.id,
      ruleVersion: rule.version,
      warnings: [
        if (input.weatherAdjustmentBp == 0) 'weather_unavailable',
        if (rawAdjustment != boundedAdjustment) 'adjustment_clamped',
      ],
      explanationFacts: {
        'plant_count': input.plantCount,
        'emitter_count': input.effectiveEmitterCount,
        'flow_ml_min': input.effectiveFlowMlMin,
        'base_ml_per_plant': rule.baseMlPerPlant,
        'bounded_adjustment_bp': boundedAdjustment,
        'weather_used': input.weatherAdjustmentBp != 0,
      },
    );
  }

  static int _roundHalfUp(int numerator, int denominator) =>
      (numerator + denominator ~/ 2) ~/ denominator;
  static int _ceilDivide(int numerator, int denominator) =>
      (numerator + denominator - 1) ~/ denominator;
}
