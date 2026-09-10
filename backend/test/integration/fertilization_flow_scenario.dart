import 'package:agrocampo_backend/src/modules/labors/domain/entities/fertilization_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/irrigation_labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';
import 'package:agrocampo_backend/src/modules/labors/infrastructure/persistence/labor_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/file_backed_database.dart';
import '../helpers/territory_fixture.dart';

void main() {
  test('fertilization keeps method, optional link and context after reopen', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    var database = fixture.open();
    await seedAgriculturalContextFixture(database);
    final repository = LaborRepository(database);
    final irrigationId = await repository.save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      type: LaborType.irrigation,
      occurredAt: DateTime.utc(2026, 1),
      details: const IrrigationLaborDetails(
        method: 'drip',
        durationMinutes: 20,
      ).toEnvelope(),
    );
    final fertilizationId = await repository.save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      type: LaborType.fertilization,
      occurredAt: DateTime.utc(2026, 2),
      details: FertilizationDetails(
        product: 'Compost',
        amount: 3,
        unit: 'kg',
        applicationMethod: FertilizationMethod.manual.code,
        irrigationLaborId: irrigationId,
      ).toEnvelope(),
    );
    await database.close();
    database = fixture.open();
    addTearDown(database.close);
    final row = await (database.select(database.labors)..where((r) => r.id.equals(fertilizationId))).getSingle();
    expect(row.detailsJson, contains(irrigationId));
    expect(row.seasonId, 'season-1');
  });
}
