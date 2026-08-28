final class IrrigationRuleSet {
  const IrrigationRuleSet({
    required this.id,
    required this.cropId,
    required this.soilTypeCode,
    required this.version,
    required this.soilMultiplierPermille,
    required this.efficiencyPermille,
    required this.minimumDurationMinutes,
    required this.maximumDurationMinutes,
    required this.sourceTitle,
    required this.sourceReference,
  });

  final String id;
  final String cropId;
  final String soilTypeCode;
  final int version;
  final int soilMultiplierPermille;
  final int efficiencyPermille;
  final int minimumDurationMinutes;
  final int maximumDurationMinutes;
  final String sourceTitle;
  final String sourceReference;

  void validate() {
    if (soilMultiplierPermille <= 0 ||
        efficiencyPermille <= 0 ||
        efficiencyPermille > 1000) {
      throw ArgumentError('rule_multiplier_invalid');
    }
    if (minimumDurationMinutes <= 0 ||
        maximumDurationMinutes < minimumDurationMinutes) {
      throw ArgumentError('rule_duration_limits_invalid');
    }
    if (sourceTitle.trim().isEmpty || sourceReference.trim().isEmpty) {
      throw ArgumentError('rule_source_required');
    }
  }
}
