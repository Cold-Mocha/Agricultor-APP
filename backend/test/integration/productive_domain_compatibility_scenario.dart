import 'package:agrocampo_backend/src/modules/labors/domain/entities/fertilization_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';
import 'package:agrocampo_backend/src/modules/labors/infrastructure/persistence/labor_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_database.dart';
import '../helpers/territory_fixture.dart';

void main() {
  test('apiary rejects a crop-only labor before any rows or outbox change', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedAgriculturalContextFixture(database);
    await database.customUpdate(
      'UPDATE sectors SET kind = ? WHERE id = ?',
      variables: [
        Variable<String>('apiary'),
        Variable<String>('sector-1'),
      ],
    );
    final repository = LaborRepository(database);
    await expectLater(
      repository.save(
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        sectorId: 'sector-1',
        type: LaborType.fertilization,
        occurredAt: DateTime.utc(2026),
        details: const FertilizationDetails(
          product: 'Compost',
          amount: 1,
          unit: 'kg',
          applicationMethod: 'manual',
        ).toEnvelope(),
      ),
      throwsStateError,
    );
    expect(await database.select(database.labors).get(), isEmpty);
    expect(await database.select(database.syncOutbox).get(), hasLength(0));
  });
}
