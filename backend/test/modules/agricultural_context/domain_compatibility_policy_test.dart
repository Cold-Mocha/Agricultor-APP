import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = DomainCompatibilityPolicy();
  const apiaryOperations = <ProductiveOperation>{
    ProductiveOperation.apiaryInspection,
    ProductiveOperation.apiaryFeeding,
    ProductiveOperation.apiaryHealth,
    ProductiveOperation.apiaryHarvest,
    ProductiveOperation.apiarySuperPlacement,
    ProductiveOperation.otherApiaryOperation,
  };

  test('allows every crop operation and rejects apiary-only operation', () {
    for (final operation in ProductiveOperation.values) {
      final decision = policy.evaluate(
        category: ProductiveCategory.crop,
        operation: operation,
        context: 'crop-sector',
      );
      if (apiaryOperations.contains(operation)) {
        expect(decision, isA<CompatibilityRejected>());
      } else {
        expect(decision, isA<CompatibilityAllowed>());
      }
    }
  });

  test('allows every apiary operation and rejects crop-only operation', () {
    for (final operation in ProductiveOperation.values) {
      final decision = policy.evaluate(
        category: ProductiveCategory.apiary,
        operation: operation,
        context: 'apiary-sector',
      );
      if (apiaryOperations.contains(operation) ||
          operation == ProductiveOperation.photoAttach) {
        expect(decision, isA<CompatibilityAllowed>());
      } else {
        expect(decision, isA<CompatibilityRejected>());
      }
    }
  });

  test('legacy category rejects all mutation operations without partial state', () {
    final decision = policy.evaluate(
      category: ProductiveCategory.legacyUnknown,
      operation: ProductiveOperation.photoAttach,
      context: 'legacy-sector',
    );
    expect(decision, isA<CompatibilityRejected>());
    expect((decision as CompatibilityRejected).code, 'legacy_category_unsupported');
  });
}
