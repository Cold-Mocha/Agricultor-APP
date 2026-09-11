part of '../app_database.dart';

Future<void> _ensureFunctionalRefinementV11Columns(AppDatabase database) async {
  const columns = <String, String>{
    'labors': 'domain_category TEXT NULL',
    'soil_measurements': 'labor_id TEXT NULL',
    'apiary_inspections': 'labor_id TEXT NULL',
  };
  for (final entry in columns.entries) {
    final rows = await database
        .customSelect('PRAGMA table_info(${entry.key})')
        .get();
    final exists = rows.any(
      (row) => row.read<String>('name') == entry.value.split(' ').first,
    );
    if (!exists) {
      await database.customStatement(
        'ALTER TABLE ${entry.key} ADD COLUMN ${entry.value}',
      );
    }
  }
}

Future<void> _upgradeFunctionalRefinementV11(
  AppDatabase database,
  Migrator migrator,
) async {
  // Keep the migration executable while older generated Drift sources are
  // present; the SQL is also safe for file-backed upgrades from v10.
  await _ensureFunctionalRefinementV11Columns(database);

  // Only the legacy apiary labor type is demonstrably apicultural. Other
  // legacy rows stay null and are exposed as legacyUnknown by the domain.
  await database.customStatement('''
    UPDATE labors SET domain_category = 'apiary'
    WHERE domain_category IS NULL AND type = 'apiary'
  ''');
  await _backfillLegacyApiaryInspections(database);

  for (final statement in _functionalRefinementV11Indexes) {
    await database.customStatement(statement);
  }
}

Future<void> _backfillLegacyApiaryInspections(AppDatabase database) async {
  final inspections = await database.customSelect('''
    SELECT id, owner_id, sector_id, task_type, beekeeper_name, hive_count,
           queen_status, brood_status, feeding_status, health_notes,
           pest_notes, super_installed, observations, inspected_at, updated_at
    FROM apiary_inspections WHERE labor_id IS NULL
  ''').get();
  for (final row in inspections) {
    final inspectionId = row.read<String>('id');
    final laborId = 'legacy-apiary-$inspectionId';
    final ownerId = row.read<String>('owner_id');
    final sectorId = row.read<String>('sector_id');
    final sector = await database
        .customSelect(
          'SELECT parcel_id FROM sectors WHERE id = ? AND owner_id = ?',
          variables: [Variable<String>(sectorId), Variable<String>(ownerId)],
        )
        .getSingleOrNull();
    if (sector == null) continue;
    final details = <String, Object?>{
      'schemaVersion': 2,
      'type': 'apiary',
      'data': {
        'taskType': row.read<String>('task_type'),
        'beekeeperName': row.read<String>('beekeeper_name'),
        'hiveCount': row.read<int>('hive_count'),
        'queenStatus': row.read<String>('queen_status'),
        'broodStatus': row.read<String>('brood_status'),
        'feedingStatus': row.read<String>('feeding_status'),
        'healthNotes': row.read<String>('health_notes'),
        'pestNotes': row.read<String>('pest_notes'),
        'superInstalled': row.read<bool>('super_installed'),
        'observations': ?row.readNullable<String>('observations'),
      },
    };
    await database.customUpdate(
      '''INSERT OR IGNORE INTO labors
         (id, owner_id, parcel_id, sector_id, type, details_json,
          details_schema_version, status, occurred_at, version, sync_state,
          updated_at)
       VALUES (?, ?, ?, ?, 'apiary', ?, 2, 'recorded', ?, 1, 'synced', ?)''',
      variables: [
        Variable<String>(laborId),
        Variable<String>(ownerId),
        Variable<String>(sector.read<String>('parcel_id')),
        Variable<String>(sectorId),
        Variable<String>(jsonEncode(details)),
        Variable<String>(row.read<String>('inspected_at')),
        Variable<String>(row.read<String>('updated_at')),
      ],
    );
    await database.customUpdate(
      'UPDATE labors SET domain_category = ? WHERE id = ?',
      variables: [Variable<String>('apiary'), Variable<String>(laborId)],
    );
    await database.customUpdate(
      'UPDATE apiary_inspections SET labor_id = ? WHERE id = ?',
      variables: [Variable<String>(laborId), Variable<String>(inspectionId)],
    );
  }
}

const _functionalRefinementV11Indexes = <String>[
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_soil_measurements_labor ON soil_measurements(labor_id) WHERE labor_id IS NOT NULL',
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_apiary_inspections_labor ON apiary_inspections(labor_id) WHERE labor_id IS NOT NULL',
  'CREATE INDEX IF NOT EXISTS idx_labors_category_history ON labors(owner_id, domain_category, occurred_at DESC, id)',
];
