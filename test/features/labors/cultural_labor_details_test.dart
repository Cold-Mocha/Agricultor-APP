import 'package:agrocampo/features/labors/domain/other_labor_details.dart';
import 'package:agrocampo/features/labors/domain/pruning_details.dart';
import 'package:agrocampo/features/labors/domain/sowing_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sowing and pruning validate positive optional measures', () {
    expect(
      const SowingDetails(
        seedQuantity: 4,
        unit: 'kg',
        spacingCentimeters: 30,
      ).toEnvelope().data['spacingCentimeters'],
      30,
    );
    expect(
      () => const PruningDetails(method: 'Manual', plantCount: 0).toEnvelope(),
      throwsArgumentError,
    );
  });

  test('other labor requires a descriptive name and description', () {
    expect(
      const OtherLaborDetails(
        name: 'Cerco',
        description: 'Reparación norte',
      ).toEnvelope().data['name'],
      'Cerco',
    );
    expect(
      () => const OtherLaborDetails(name: '', description: '').toEnvelope(),
      throwsArgumentError,
    );
  });
}
