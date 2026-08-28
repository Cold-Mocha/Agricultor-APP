import 'package:agrocampo/features/irrigation/domain/irrigation_rule_set.dart';

final class IrrigationCalculationInput {
  const IrrigationCalculationInput({
    required this.plantCount,
    required this.flowMilliLitersPerHourPerPlant,
    required this.requestedMinutes,
  });

  final int plantCount;
  final int flowMilliLitersPerHourPerPlant;
  final int requestedMinutes;
}

sealed class IrrigationCalculationResult {
  const IrrigationCalculationResult();
}

final class IrrigationUnavailable extends IrrigationCalculationResult {
  const IrrigationUnavailable(this.code);
  final String code;
}

final class IrrigationEstimateResult extends IrrigationCalculationResult {
  const IrrigationEstimateResult({
    required this.estimatedLitersMilli,
    required this.recommendedMinutes,
    required this.ruleId,
    required this.ruleVersion,
    required this.warnings,
  });

  final int estimatedLitersMilli;
  final int recommendedMinutes;
  final String ruleId;
  final int ruleVersion;
  final List<String> warnings;
}

abstract final class IrrigationCalculator {
  static IrrigationCalculationResult calculate(
    IrrigationCalculationInput input, {
    IrrigationRuleSet? rule,
  }) {
    if (rule == null) {
      return const IrrigationUnavailable('crop_rule_unavailable');
    }
    rule.validate();
    if (input.plantCount <= 0 ||
        input.flowMilliLitersPerHourPerPlant <= 0 ||
        input.requestedMinutes <= 0) {
      return const IrrigationUnavailable('invalid_input');
    }
    final minutes = input.requestedMinutes.clamp(
      rule.minimumDurationMinutes,
      rule.maximumDurationMinutes,
    );
    final numerator =
        input.plantCount *
        input.flowMilliLitersPerHourPerPlant *
        minutes *
        rule.soilMultiplierPermille *
        1000;
    final denominator = 60 * 1000 * rule.efficiencyPermille;
    final litersMilli = (numerator + denominator ~/ 2) ~/ denominator;
    return IrrigationEstimateResult(
      estimatedLitersMilli: litersMilli,
      recommendedMinutes: minutes,
      ruleId: rule.id,
      ruleVersion: rule.version,
      warnings: [
        if (minutes != input.requestedMinutes)
          'duration_clamped_to_validated_limits',
      ],
    );
  }
}
