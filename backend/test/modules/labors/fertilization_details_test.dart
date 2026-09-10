import 'package:agrocampo_backend/src/modules/labors/domain/entities/fertilization_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('manual, foliar and fertigation keep their declared method without dose calculation', () {
    for (final method in FertilizationMethod.values) {
      final details = FertilizationDetails(
        product: 'Abono',
        amount: 2,
        unit: 'kg',
        applicationMethod: method.code,
        observations: 'Aplicación registrada',
      ).toEnvelope();
      expect(details.type, LaborType.fertilization);
      expect(details.data['applicationMethod'], method.code);
      expect(details.data.containsKey('recommendedDose'), isFalse);
    }
  });

  test('invalid and incompatible fields are rejected or omitted explicitly', () {
    expect(
      () => const FertilizationDetails(
        product: '',
        amount: 1,
        unit: 'kg',
        applicationMethod: 'manual',
      ).toEnvelope(),
      throwsArgumentError,
    );
    final details = const FertilizationDetails(
      product: 'Abono',
      amount: 1,
      unit: 'kg',
      applicationMethod: 'manual',
    ).toEnvelope();
    expect(details.data.containsKey('irrigationLaborId'), isFalse);
  });
}
