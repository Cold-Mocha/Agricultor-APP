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
    this.reviewer,
    this.approvedAt,
    this.approvedVectorCount = 0,
    this.baseMlPerPlant = 1000,
    this.minimumAdjustmentBp = 5000,
    this.maximumAdjustmentBp = 15000,
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
  final String? reviewer;
  final DateTime? approvedAt;
  final int approvedVectorCount;
  final int baseMlPerPlant;
  final int minimumAdjustmentBp;
  final int maximumAdjustmentBp;

  bool get releaseApproved =>
      sourceTitle.trim().isNotEmpty &&
      sourceReference.trim().isNotEmpty &&
      (reviewer?.trim().isNotEmpty ?? false) &&
      approvedAt != null &&
      approvedVectorCount >= 20;

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
    if (!releaseApproved) throw ArgumentError('rule_release_gate_not_met');
    if (baseMlPerPlant <= 0 ||
        minimumAdjustmentBp <= 0 ||
        maximumAdjustmentBp < minimumAdjustmentBp) {
      throw ArgumentError('rule_adjustment_bounds_invalid');
    }
  }
}
