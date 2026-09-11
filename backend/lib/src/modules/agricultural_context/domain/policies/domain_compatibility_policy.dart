import '../../../../shared/contracts/productive_domain.dart';

/// Single backend authority for the category × operation matrix.
final class DomainCompatibilityPolicy {
  const DomainCompatibilityPolicy();

  List<ProductiveOperation> allowedOperations(ProductiveCategory category) =>
      ProductiveOperation.values
          .where(
            (operation) =>
                evaluate(category: category, operation: operation).isAllowed,
          )
          .toList(growable: false);

  CompatibilityDecision evaluate({
    required ProductiveCategory category,
    required ProductiveOperation operation,
    Object? context,
  }) {
    if (category == ProductiveCategory.legacyUnknown) {
      return CompatibilityRejected(
        code: 'legacy_category_unsupported',
        message: 'El Sector legado no admite nuevas operaciones.',
        context: context,
      );
    }

    final isCropOperation = <ProductiveOperation>{
      ProductiveOperation.soilMeasure,
      ProductiveOperation.irrigationRecord,
      ProductiveOperation.dripBasicEstimate,
      ProductiveOperation.irrigationAdvancedRecommendation,
      ProductiveOperation.fertilizationRecord,
      ProductiveOperation.phytosanitaryRecord,
      ProductiveOperation.cultivationRecord,
      ProductiveOperation.vegetableHarvest,
      ProductiveOperation.otherVegetableLabor,
    }.contains(operation);
    final isApiaryOperation = <ProductiveOperation>{
      ProductiveOperation.apiaryInspection,
      ProductiveOperation.apiaryFeeding,
      ProductiveOperation.apiaryHealth,
      ProductiveOperation.apiaryHarvest,
      ProductiveOperation.apiarySuperPlacement,
      ProductiveOperation.otherApiaryOperation,
    }.contains(operation);

    if (operation == ProductiveOperation.photoAttach) {
      return CompatibilityAllowed(context: context);
    }
    if ((category == ProductiveCategory.crop && isCropOperation) ||
        (category == ProductiveCategory.apiary && isApiaryOperation)) {
      return CompatibilityAllowed(context: context);
    }

    final code = category == ProductiveCategory.apiary
        ? 'operation_not_valid_for_apiary'
        : 'operation_requires_apiary';
    return CompatibilityRejected(
      code: code,
      message: category == ProductiveCategory.apiary
          ? 'La operación no corresponde a una unidad apícola.'
          : 'La operación requiere una unidad apícola.',
      context: context,
    );
  }
}
