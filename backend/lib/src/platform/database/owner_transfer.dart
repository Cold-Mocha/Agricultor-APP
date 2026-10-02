import 'dart:convert';

import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_request_hash.dart';
import 'package:drift/drift.dart';

/// Reassigns every record of a device-local owner to an authenticated owner
/// in one transaction, so data created in a local-only build is uploaded by
/// the normal synchronization after the first online sign-in.
final class OwnerTransfer {
  const OwnerTransfer(this._database);

  /// Tables keyed by owner plus another column; a row that already exists for
  /// the target owner wins and the local duplicate is dropped.
  static const _mergedTables = {'app_preferences', 'sync_cursors'};

  final AppDatabase _database;

  Future<void> transfer({required String from, required String to}) async {
    if (from == to) return;
    await _database.transaction(() async {
      for (final table in _database.allTables) {
        final name = table.actualTableName;
        if (!table.$columns.any((column) => column.name == 'owner_id')) {
          continue;
        }
        if (_mergedTables.contains(name)) {
          await _database.customUpdate(
            'UPDATE OR IGNORE $name SET owner_id = ? WHERE owner_id = ?',
            variables: [Variable(to), Variable(from)],
          );
          await _database.customUpdate(
            'DELETE FROM $name WHERE owner_id = ?',
            variables: [Variable(from)],
          );
        } else {
          await _database.customUpdate(
            'UPDATE $name SET owner_id = ? WHERE owner_id = ?',
            variables: [Variable(to), Variable(from)],
          );
        }
      }
      await _database.customUpdate(
        'UPDATE OR IGNORE local_profiles SET id = ? WHERE id = ?',
        variables: [Variable(to), Variable(from)],
      );
      await _database.customUpdate(
        'DELETE FROM local_profiles WHERE id = ?',
        variables: [Variable(from)],
      );
      await _rewritePendingPayloads(from: from, to: to);
    });
  }

  Future<void> _rewritePendingPayloads({
    required String from,
    required String to,
  }) async {
    final outbox = _database.syncOutbox;
    final rows =
        await (_database.select(outbox)
              ..where((row) => row.ownerId.equals(to))
              ..where((row) => row.payloadJson.contains(from)))
            .get();
    for (final row in rows) {
      final payload = _replaceOwner(jsonDecode(row.payloadJson), from, to);
      await (_database.update(
        outbox,
      )..where((item) => item.operationId.equals(row.operationId))).write(
        SyncOutboxCompanion(
          payloadJson: Value(jsonEncode(payload)),
          requestHash: Value(
            syncRequestHash(
              aggregateType: row.aggregateType,
              aggregateId: row.aggregateId,
              mutationKind: row.mutationKind,
              baseVersion: row.baseVersion,
              payload: payload as Object,
            ),
          ),
        ),
      );
    }
  }

  static Object? _replaceOwner(Object? value, String from, String to) =>
      switch (value) {
        final String text when text == from => to,
        final Map<String, Object?> map => {
          for (final entry in map.entries)
            entry.key: _replaceOwner(entry.value, from, to),
        },
        final List<Object?> list => [
          for (final item in list) _replaceOwner(item, from, to),
        ],
        _ => value,
      };
}
