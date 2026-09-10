enum ProductiveCategory {
  crop('crop'),
  apiary('apiary'),
  legacyUnknown('legacyUnknown');

  const ProductiveCategory(this.code);

  final String code;

  static ProductiveCategory fromCode(String? value) => values.firstWhere(
    (category) => category.code == value,
    orElse: () => ProductiveCategory.legacyUnknown,
  );
}

enum ProductiveOperation {
  soilMeasure('soilMeasure'),
  irrigationRecord('irrigationRecord'),
  dripBasicEstimate('dripBasicEstimate'),
  irrigationAdvancedRecommendation('irrigationAdvancedRecommendation'),
  fertilizationRecord('fertilizationRecord'),
  phytosanitaryRecord('phytosanitaryRecord'),
  cultivationRecord('cultivationRecord'),
  vegetableHarvest('vegetableHarvest'),
  otherVegetableLabor('otherVegetableLabor'),
  apiaryInspection('apiaryInspection'),
  apiaryFeeding('apiaryFeeding'),
  apiaryHealth('apiaryHealth'),
  apiaryHarvest('apiaryHarvest'),
  apiarySuperPlacement('apiarySuperPlacement'),
  otherApiaryOperation('otherApiaryOperation'),
  photoAttach('photoAttach');

  const ProductiveOperation(this.code);

  final String code;

  static ProductiveOperation? fromCode(String? value) {
    for (final operation in values) {
      if (operation.code == value) return operation;
    }
    return null;
  }
}

sealed class CompatibilityDecision {
  const CompatibilityDecision({required this.context});

  final Object? context;

  bool get isAllowed => this is CompatibilityAllowed;
}

final class CompatibilityAllowed extends CompatibilityDecision {
  const CompatibilityAllowed({super.context});
}

final class CompatibilityRejected extends CompatibilityDecision {
  const CompatibilityRejected({
    required this.code,
    required this.message,
    super.context,
  });

  final String code;
  final String message;
}
