import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/database/functional_core_v9.dart';
import '../../helpers/file_backed_database.dart';

void main() {
  test('domain row and pending outbox survive close and reopen', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);

    var database = fixture.open();
    await SectorRepository(database).save(
      ownerId: 'owner-1',
      number: 1,
      name: 'Sector persistente',
      polygon: const [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.73, -72.59),
      ],
    );
    await database.close();

    database = fixture.open();
    addTearDown(database.close);
    final sector = await database.select(database.sectors).getSingle();
    final operation = await database.select(database.syncOutbox).getSingle();

    expect(sector.name, 'Sector persistente');
    expect(operation.aggregateId, sector.id);
    expect(operation.state, 'pending');
  });

  test('populated current fixture preserves rows in every table', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);

    var database = fixture.open();
    await populateCurrentSchema(database);
    await database.close();

    database = fixture.open();
    addTearDown(database.close);
    for (final tableName in currentSchemaTableNames) {
      final count = await database
          .customSelect('SELECT COUNT(*) AS amount FROM $tableName')
          .map((row) => row.read<int>('amount'))
          .getSingle();
      expect(count, 1, reason: '$tableName should survive reopen');
    }
  });
}
