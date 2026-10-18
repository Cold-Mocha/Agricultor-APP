import 'package:agrocampo_backend/src/modules/irrigation/domain/entities/irrigation_record.dart';

enum IrrigationFlowScope { total, perEmitter, perPlant }

/// Presentation-safe draft. Units are kept as entered; canonical values are
/// produced by the backend before confirmation.
final class IrrigationDraft {
  const IrrigationDraft({
    required this.sectorId,
    required this.method,
    required this.duration,
    this.flow,
    this.flowScope = IrrigationFlowScope.total,
    this.emitterOrPlantCount,
    this.pressure,
    this.appliedVolume,
  });

  final String sectorId;
  final IrrigationType method;
  final String duration;
  final String? flow;
  final IrrigationFlowScope flowScope;
  final int? emitterOrPlantCount;
  final String? pressure;
  final String? appliedVolume;

  String get previewFingerprint => [
    sectorId,
    method.name,
    duration.trim(),
    flow?.trim() ?? '',
    flowScope.name,
    '${emitterOrPlantCount ?? ''}',
    pressure?.trim() ?? '',
    appliedVolume?.trim() ?? '',
  ].join('|');
}

final class BasicEstimateApplicability {
  const BasicEstimateApplicability({
    required this.method,
    required this.available,
    required this.requiredInputs,
    required this.formulaVersion,
    this.unavailableCode,
  });

  final IrrigationType method;
  final bool available;
  final List<String> requiredInputs;
  final int formulaVersion;
  final String? unavailableCode;
}

final class AdvancedRecommendationApplicability {
  const AdvancedRecommendationApplicability({
    this.available = false,
    this.unavailableCode = 'crop_rule_unavailable',
  });

  final bool available;
  final String unavailableCode;
}

sealed class BasicEstimateOutcome {
  const BasicEstimateOutcome();
}

final class BasicEstimateAvailable extends BasicEstimateOutcome {
  const BasicEstimateAvailable({
    required this.volumeMl,
    required this.submittedInputs,
    required this.canonicalInputs,
    required this.formulaVersion,
    required this.roundingPolicy,
    required this.previewFingerprint,
  });

  final int volumeMl;
  final IrrigationDraft submittedInputs;
  final Map<String, Object?> canonicalInputs;
  final int formulaVersion;
  final String roundingPolicy;
  final String previewFingerprint;
}

final class BasicEstimateUnavailable extends BasicEstimateOutcome {
  const BasicEstimateUnavailable({
    required this.code,
    required this.missingInputs,
    required this.preservedDraft,
  });

  final String code;
  final List<String> missingInputs;
  final IrrigationDraft preservedDraft;
}

final class BasicEstimateInvalid extends BasicEstimateOutcome {
  const BasicEstimateInvalid({
    required this.fieldErrors,
    required this.preservedDraft,
  });

  final List<String> fieldErrors;
  final IrrigationDraft preservedDraft;
}
