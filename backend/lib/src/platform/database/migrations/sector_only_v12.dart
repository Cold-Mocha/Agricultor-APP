part of '../app_database.dart';

/// Module 004 removed parcels and approved a data reset: every schema older
/// than v12 is dropped and recreated empty, including sync state.
Future<void> _resetForSectorOnlyV12(
  AppDatabase database,
  Migrator migrator,
) async {
  await database.customStatement('PRAGMA foreign_keys = OFF');
  final tables = await database.customSelect('''
    SELECT name FROM sqlite_master
    WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
  ''').get();
  for (final table in tables) {
    await database.customStatement(
      'DROP TABLE IF EXISTS "${table.read<String>('name')}"',
    );
  }
  await migrator.createAll();
  await database.customStatement('PRAGMA foreign_keys = ON');
}

const _sectorOnlyV12Indexes = <String>[
  'CREATE INDEX IF NOT EXISTS idx_outbox_eligible ON sync_outbox(owner_id, state, next_attempt_at, created_at)',
  'CREATE INDEX IF NOT EXISTS idx_sectors_owner ON sectors(owner_id, deleted_at, number)',
  'CREATE INDEX IF NOT EXISTS idx_seasons_status ON agricultural_seasons(owner_id, sector_id, status)',
  'CREATE INDEX IF NOT EXISTS idx_assignments_sector ON crop_seasons(owner_id, sector_id, starts_on DESC)',
  'CREATE INDEX IF NOT EXISTS idx_assignments_season ON crop_seasons(owner_id, agricultural_season_id, sector_id)',
  'CREATE INDEX IF NOT EXISTS idx_labors_history ON labors(owner_id, sector_id, season_id, occurred_at DESC, type, id)',
  'CREATE INDEX IF NOT EXISTS idx_labors_category_history ON labors(owner_id, domain_category, occurred_at DESC, id)',
  'CREATE INDEX IF NOT EXISTS idx_soil_history ON soil_measurements(owner_id, sector_id, measured_at DESC, id)',
  'CREATE INDEX IF NOT EXISTS idx_irrigation_config_current ON sector_irrigation_configs(owner_id, sector_id, method, effective_from DESC)',
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_production_labor ON production_records(labor_id) WHERE labor_id IS NOT NULL',
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_soil_measurements_labor ON soil_measurements(labor_id) WHERE labor_id IS NOT NULL',
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_apiary_inspections_labor ON apiary_inspections(labor_id) WHERE labor_id IS NOT NULL',
];
