part of '../app_database.dart';

/// Before v13, `sectors` had a table-level `UNIQUE(owner_id, number)`
/// constraint, enforced even against soft-deleted rows. Renaming or
/// recreating a sector to reuse a number that belonged to a now-deleted
/// sector failed with a UNIQUE constraint violation, even though that
/// number is free from the owner's point of view. SQLite can't drop a
/// table-level constraint in place, so the table is rebuilt without it;
/// every row (and its id, which other tables reference) is preserved.
Future<void> _allowSectorNumberReuseV13(
  AppDatabase database,
  Migrator migrator,
) async {
  await database.customStatement('PRAGMA foreign_keys = OFF');
  await database.customStatement('ALTER TABLE sectors RENAME TO sectors_old');
  await migrator.createTable(database.sectors);
  await database.customStatement('''
    INSERT INTO sectors (
      id, owner_id, number, name, kind, polygon_json, area_square_meters,
      version, sync_state, server_updated_at, last_sync_error_code,
      updated_at, deleted_at
    )
    SELECT
      id, owner_id, number, name, kind, polygon_json, area_square_meters,
      version, sync_state, server_updated_at, last_sync_error_code,
      updated_at, deleted_at
    FROM sectors_old
  ''');
  await database.customStatement('DROP TABLE sectors_old');
  await database.customStatement('PRAGMA foreign_keys = ON');
  for (final statement in _sectorNumberReuseV13Indexes) {
    await database.customStatement(statement);
  }
}

const _sectorNumberReuseV13Indexes = <String>[
  'CREATE UNIQUE INDEX IF NOT EXISTS idx_sectors_number_active '
      'ON sectors(owner_id, number) WHERE deleted_at IS NULL',
];
