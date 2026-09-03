import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/database/functional_core_v9.dart';
import '../../helpers/file_backed_database.dart';

void main() {
  test('domain row and pending outbox survive close and reopen', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);

    var database = fixture.open();
    await ParcelRepository(database)
        .save(ownerId: 'owner-1', name: 'Parcela persistente');
    await database.close();

    database = fixture.open();
    addTearDown(database.close);
    final parcel = await database.select(database.parcels).getSingle();
    final operation = await database.select(database.syncOutbox).getSingle();

    expect(parcel.name, 'Parcela persistente');
    expect(operation.aggregateId, parcel.id);
    expect(operation.state, 'pending');
  });

  test('populated v9 fixture preserves rows in all 24 tables', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);

    var database = fixture.open();
    await populateFunctionalCoreV9(database);
    await database.close();

    database = fixture.open();
    addTearDown(database.close);
    for (final tableName in functionalCoreV9TableNames) {
      final count = await database
          .customSelect('SELECT COUNT(*) AS amount FROM $tableName')
          .map((row) => row.read<int>('amount'))
          .getSingle();
      expect(count, 1, reason: '$tableName should survive reopen');
    }
  });
}
