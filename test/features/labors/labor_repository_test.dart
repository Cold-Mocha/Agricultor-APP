import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test('Otra labor requires descriptive name and observations', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedTerritoryFixture(database);
    final repository = LaborRepository(database);

    await expectLater(
      repository.save(
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        sectorId: 'sector-1',
        type: LaborType.other,
        occurredAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
    await repository.save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      type: LaborType.other,
      customName: 'Reparar cerco',
      notes: 'Tramo norte',
      occurredAt: DateTime.utc(2026),
    );
    expect(
      (await database.select(database.labors).getSingle()).customName,
      'Reparar cerco',
    );
  });
}
