import 'package:agrocampo_backend/src/modules/labors/infrastructure/persistence/labor_repository.dart';
import 'package:agrocampo_backend/src/modules/production/domain/entities/harvest_input.dart';
import 'package:agrocampo_backend/src/modules/production/infrastructure/persistence/production_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test('harvest keeps crop, quantity, unit and traceability', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedAgriculturalContextFixture(database);
    await ProductionRepository(database, LaborRepository(database)).save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      input: HarvestInput(
        cropId: 'trigo',
        quantity: 1250,
        unit: 'kg',
        harvestedAt: DateTime.utc(2026, 2),
      ),
    );
    final row = await database.select(database.productionRecords).getSingle();
    expect(row.cropId, 'trigo');
    expect(row.quantity, 1250);
    expect(await database.select(database.syncOutbox).get(), hasLength(1));
  });
}
