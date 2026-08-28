import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/core/sync/sync_gateway.dart';
import 'package:drift/drift.dart';

final class SyncRunResult {
  const SyncRunResult({
    required this.pushed,
    required this.pulled,
    required this.conflicts,
  });

  final int pushed;
  final int pulled;
  final int conflicts;
}

final class SyncCoordinator {
  SyncCoordinator(this._database, this._gateway);

  static const stream = 'owner-changes-v1';

  final AppDatabase _database;
  final SyncGateway _gateway;

  Future<SyncRunResult> synchronize(String ownerId) async {
    final pending =
        await (_database.select(_database.syncOutbox)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) & row.state.equals('pending'),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
            .get();
    var pushed = 0;
    var conflictCount = 0;
    if (pending.isNotEmpty) {
      final result = await _gateway.push(
        ownerId: ownerId,
        operations: pending
            .map(
              (row) => PushMutation(
                operationId: row.operationId,
                aggregateType: row.aggregateType,
                aggregateId: row.aggregateId,
                kind: row.mutationKind,
                baseVersion: row.baseVersion,
                payloadJson: row.payloadJson,
              ),
            )
            .toList(growable: false),
      );
      for (final operationId in result.acknowledgedOperationIds) {
        pushed +=
            await (_database.update(_database.syncOutbox)
                  ..where((row) => row.operationId.equals(operationId)))
                .write(const SyncOutboxCompanion(state: Value('done')));
      }
      conflictCount += await _recordConflicts(ownerId, result.conflicts);
    }

    final cursor = await _database.syncCursorDao.read(ownerId, stream);
    final pull = await _gateway.pull(ownerId: ownerId, afterCursor: cursor);
    await _applyChanges(ownerId, pull.changes);
    conflictCount += await _recordConflicts(ownerId, pull.conflicts);
    await _database.syncCursorDao.write(ownerId, stream, pull.nextCursor);
    return SyncRunResult(
      pushed: pushed,
      pulled: pull.changes.length,
      conflicts: conflictCount,
    );
  }

  Future<void> _applyChanges(String ownerId, List<RemoteChange> changes) =>
      _database.transaction(() async {
        for (final change in changes) {
          if (change.aggregateType != 'parcel') {
            continue;
          }
          final payload =
              jsonDecode(change.payloadJson) as Map<String, Object?>;
          await _database
              .into(_database.parcels)
              .insertOnConflictUpdate(
                ParcelsCompanion.insert(
                  id: payload['id']! as String,
                  ownerId: ownerId,
                  name: payload['name']! as String,
                  locality: Value(payload['locality'] as String?),
                  isActive: Value(payload['is_active'] as bool? ?? false),
                  isArchived: Value(payload['is_archived'] as bool? ?? false),
                  version: Value((payload['version'] as num?)?.toInt() ?? 1),
                  updatedAt: DateTime.parse(payload['updated_at']! as String)
                      .toUtc(),
                ),
              );
        }
      });

  Future<int> _recordConflicts(
    String ownerId,
    List<RemoteConflict> conflicts,
  ) async {
    for (final conflict in conflicts) {
      await _database.conflictDao.record(
        SyncConflictsCompanion.insert(
          conflictId: conflict.id,
          ownerId: ownerId,
          aggregateType: conflict.aggregateType,
          aggregateId: conflict.aggregateId,
          localJson: conflict.localJson,
          remoteJson: conflict.remoteJson,
          detectedAt: DateTime.now().toUtc(),
        ),
      );
    }
    return conflicts.length;
  }
}
