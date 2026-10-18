import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('categories round trip and unknown values stay readable', () {
    expect(ProductiveCategory.fromCode('crop'), ProductiveCategory.crop);
    expect(ProductiveCategory.fromCode('apiary').code, 'apiary');
    expect(
      ProductiveCategory.fromCode('future'),
      ProductiveCategory.legacyUnknown,
    );
  });

  test('operation codes are stable and unknown codes are nullable', () {
    expect(
      ProductiveOperation.fromCode('dripBasicEstimate'),
      ProductiveOperation.dripBasicEstimate,
    );
    expect(ProductiveOperation.fromCode('future'), isNull);
  });

  test('compatibility decisions are immutable and typed', () {
    const allowed = CompatibilityAllowed(context: 'sector-1');
    const rejected = CompatibilityRejected(
      code: 'operation_not_valid_for_apiary',
      message: 'No corresponde',
      context: 'sector-2',
    );
    expect(allowed.isAllowed, isTrue);
    expect(rejected.isAllowed, isFalse);
    expect(rejected.code, 'operation_not_valid_for_apiary');
  });
}
