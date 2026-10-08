import 'dart:io';

import 'package:drift/native.dart';

import '../../generated/migrations/schema_v12.dart' as v12;

/// A v12 database (pre-fix) with a sector tombstoned at number 1 and an
/// active sector at number 10, the exact shape that used to make renaming
/// the active sector to 1 fail: v12's `sectors` table still enforces
/// `UNIQUE(owner_id, number)` against the deleted row.
Future<void> createV12WithDeletedSectorNumber(File file) async {
  final database = v12.DatabaseAtV12(NativeDatabase(file));
  const timestamp = '2026-01-02T12:00:00.000Z';
  final statements = <String>[
    "INSERT INTO sectors (id, owner_id, number, name, kind, polygon_json, area_square_meters, version, sync_state, updated_at, deleted_at) VALUES ('sector-deleted','owner-1',1,'Cuadrante 1 original','crop','[]',100,2,'synced','$timestamp','$timestamp')",
    "INSERT INTO sectors (id, owner_id, number, name, kind, polygon_json, area_square_meters, version, sync_state, updated_at) VALUES ('sector-active','owner-1',10,'Cuadrante 10','crop','[]',100,1,'synced','$timestamp')",
  ];
  try {
    for (final statement in statements) {
      await database.customStatement(statement);
    }
  } finally {
    await database.close();
  }
}
