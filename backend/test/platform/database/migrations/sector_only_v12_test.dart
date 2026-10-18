import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/database/functional_core_v9.dart';
import '../../../helpers/file_backed_database.dart';

void main() {
  test('pre-v12 data is reset to an empty sector-only schema', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    await createPopulatedFunctionalCoreV9(fixture.databaseFile);

    final database = fixture.open();
    addTearDown(database.close);

    final version = await database
        .customSelect('PRAGMA user_version')
        .map((row) => row.read<int>('user_version'))
        .getSingle();
    expect(version, 13);

    final parcelTables = await database
        .customSelect(
          "SELECT COUNT(*) AS amount FROM sqlite_master WHERE type = 'table' AND name = 'parcels'",
        )
        .map((row) => row.read<int>('amount'))
        .getSingle();
    expect(parcelTables, 0, reason: 'module 004 removes parcels');

    for (final table in currentSchemaTableNames) {
      final count = await database
          .customSelect('SELECT COUNT(*) AS amount FROM $table')
          .map((row) => row.read<int>('amount'))
          .getSingle();
      expect(count, 0, reason: '$table must be emptied by the v12 reset');
    }
    final sectorColumns = await database
        .customSelect('PRAGMA table_info(sectors)')
        .map((row) => row.read<String>('name'))
        .get();
    expect(sectorColumns, isNot(contains('parcel_id')));
  });

  test('the reset keeps foreign keys enforced afterwards', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    await createPopulatedFunctionalCoreV9(fixture.databaseFile);

    final database = fixture.open();
    addTearDown(database.close);

    await expectLater(
      database.customStatement(
        "INSERT INTO agricultural_seasons (id, owner_id, sector_id, name, starts_on, updated_at) VALUES ('s', 'o', 'missing', 'T', '2026-01-01', '2026-01-01')",
      ),
      throwsA(isA<SqliteException>()),
    );
  });
}
