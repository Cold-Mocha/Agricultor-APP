import 'package:agrocampo_backend/src/modules/labors/domain/entities/other_labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/pruning_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/sowing_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/cultivation_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';
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

  test('cultivation keeps performed work, observed state and optional fields', () {
    final envelope = const CultivationDetails(
      performedWork: 'Desmalezado',
      observedState: 'Lote limpio',
      variety: 'A-1',
      affectedPlants: 12,
      observations: 'Sin daños',
    ).toEnvelope();
    expect(envelope.type, LaborType.cultivation);
    expect(envelope.data['affectedPlants'], 12);
    expect(envelope.data['observations'], 'Sin daños');
  });
}
