import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/database/functional_core_v9.dart';
import '../../../helpers/file_backed_database.dart';

void main() {
  test('migrates populated v9 to v10 without losing existing rows', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    await createPopulatedFunctionalCoreV9(fixture.databaseFile);

    final database = fixture.open();
    addTearDown(database.close);

    final version = await database
        .customSelect('PRAGMA user_version')
        .map((row) => row.read<int>('user_version'))
        .getSingle();
    expect(version, 10);

    for (final tableName in functionalCoreV9TableNames) {
      final count = await database
          .customSelect('SELECT COUNT(*) AS amount FROM $tableName')
          .map((row) => row.read<int>('amount'))
          .getSingle();
      expect(count, 1, reason: '$tableName must be preserved');
    }
    expect(
      await database.select(database.agriculturalSeasons).get(),
      hasLength(1),
    );
    expect(
      (await database.select(database.cropSeasons).getSingle())
          .agriculturalSeasonId,
      'imported-season-parcel-1',
    );
    expect(
      (await database.select(database.syncOutbox).getSingle()).state,
      'pending',
    );
    expect(
      (await database.select(database.aiMessages).getSingle()).clientMessageId,
      'message-1',
    );
  });

  test(
    'fresh v10 schema contains exactly 26 domain and technical tables',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      final database = fixture.open();
      addTearDown(database.close);

      final tables = await database
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
          )
          .get();
      expect(tables, hasLength(26));
    },
  );

  test('validation failure rolls the complete v9 upgrade back', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    await createPopulatedFunctionalCoreV9(fixture.databaseFile);
    await corruptFunctionalCoreV9AssignmentParent(fixture.databaseFile);

    final database = fixture.open();
    await expectLater(
      database.customSelect('SELECT 1').get(),
      throwsA(isA<StateError>()),
    );
    await database.close();

    final state = await inspectV9File(fixture.databaseFile);
    expect(state.version, 9);
    expect(state.hasAgriculturalSeasons, isFalse);
  });
}
