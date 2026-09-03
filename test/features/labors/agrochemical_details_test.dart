import 'package:agrocampo/features/labors/domain/fertilization_details.dart';
import 'package:agrocampo/features/labors/domain/phytosanitary_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fertilization validates product, positive amount, unit and method', () {
    final envelope = const FertilizationDetails(
      product: 'Compost',
      amount: 12,
      unit: 'kg',
      applicationMethod: 'Banda',
    ).toEnvelope();
    expect(envelope.data['amount'], 12);
    expect(
      () => const FertilizationDetails(
        product: '',
        amount: -1,
        unit: '',
        applicationMethod: '',
      ).toEnvelope(),
      throwsArgumentError,
    );
  });

  test('phytosanitary validates target, dose and safety interval', () {
    final envelope = const PhytosanitaryDetails(
      product: 'Jabón potásico',
      target: 'Pulgón',
      dose: 2,
      unit: 'ml/L',
      safetyIntervalDays: 1,
    ).toEnvelope();
    expect(envelope.data['target'], 'Pulgón');
    expect(
      () => const PhytosanitaryDetails(
        product: 'X',
        target: '',
        dose: 0,
        unit: 'ml/L',
        safetyIntervalDays: -1,
      ).toEnvelope(),
      throwsArgumentError,
    );
  });
}
