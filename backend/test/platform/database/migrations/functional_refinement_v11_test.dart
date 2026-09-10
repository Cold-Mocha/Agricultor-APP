import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;

import '../../../fixtures/database/functional_core_v9.dart';
import '../../../helpers/file_backed_database.dart';
import '../../../generated/migrations/schema_v9.dart' as v9;
import 'package:drift/native.dart';

void main() {
  test('v10-compatible data migrates to v11 without losing history or links', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    await createPopulatedFunctionalCoreV9(fixture.databaseFile);

    final database = fixture.open();
    addTearDown(database.close);

    final version = await database
        .customSelect('PRAGMA user_version')
        .map((row) => row.read<int>('user_version'))
        .getSingle();
    expect(version, 11);

    for (final table in const [
      'labors',
      'soil_measurements',
      'apiary_inspections',
      'sync_outbox',
      'sync_cursors',
      'sync_conflicts',
    ]) {
      final count = await database
          .customSelect('SELECT COUNT(*) AS amount FROM $table')
          .map((row) => row.read<int>('amount'))
          .getSingle();
      expect(count, greaterThanOrEqualTo(1), reason: '$table must be preserved');
    }

    for (final entry in const {
      'labors': 'domain_category',
      'soil_measurements': 'labor_id',
      'apiary_inspections': 'labor_id',
    }.entries) {
      final columns = await database
          .customSelect('PRAGMA table_info(${entry.key})')
          .map((row) => row.read<String>('name'))
          .get();
      expect(columns, contains(entry.value));
    }

    final apiaryCategory = await database
        .customSelect(
          "SELECT domain_category FROM labors WHERE id = 'labor-1'",
        )
        .map((row) => row.readNullable<String>('domain_category'))
        .getSingle();
    expect(apiaryCategory, isNull, reason: 'unproven legacy labor remains unknown');

    final indexes = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type='index' AND name IN ('idx_soil_measurements_labor','idx_apiary_inspections_labor')",
        )
        .get();
    expect(indexes, hasLength(2));
  });
  test('legacy apiary inspection receives a deterministic labor link without crop context', () async {
  final fixture = await FileBackedDatabaseFixture.create();
  addTearDown(fixture.dispose);
  await createPopulatedFunctionalCoreV9(fixture.databaseFile);
  final legacy = v9.DatabaseAtV9(NativeDatabase(fixture.databaseFile));
  await legacy.customStatement("UPDATE sectors SET kind = 'apiary' WHERE id = 'sector-1'");
  await legacy.close();
  final database = fixture.open();
  addTearDown(database.close);
  final link = await database.customSelect(
    "SELECT labor_id FROM apiary_inspections WHERE id = 'apiary-1'",
  ).getSingle();
  final laborId = link.readNullable<String>('labor_id');
  expect(laborId, 'legacy-apiary-apiary-1');
  final labor = await (database.select(database.labors)..where((row) => row.id.equals(laborId!))).getSingle();
  expect(labor.type, 'apiary');
  final category = await database.customSelect(
    'SELECT domain_category FROM labors WHERE id = ?',
    variables: [drift.Variable<String>(laborId!)],
  ).getSingle();
  expect(category.read<String>('domain_category'), 'apiary');
  expect(labor.seasonId, isNull);
  expect(labor.cropAssignmentId, isNull);
  });
}
