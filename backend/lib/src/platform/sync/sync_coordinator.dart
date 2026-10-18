import 'dart:async';

import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/aggregate_sync_registry.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/sync_contract.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_gateway.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_retry_policy.dart';
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

final class SyncRefreshResult {
  const SyncRefreshResult({
    required this.pulled,
    required this.unavailableSectorIds,
    required this.localChangesProtected,
  });
  final int pulled;
  final List<String> unavailableSectorIds;
  final bool localChangesProtected;
}

final class SyncCoordinator {
  SyncCoordinator(
    this._database,
    this._gateway, {
    required this._registry,
    this._retryPolicy = const SyncRetryPolicy(),
  }) : assert(_retryPolicy.baseSeconds > 0);

  static const stream = 'owner-changes-v1';

  final AppDatabase _database;
  final SyncGateway _gateway;
  final AggregateSyncRegistry _registry;
  final SyncRetryPolicy _retryPolicy;
  Future<void> _tail = Future.value();

  Future<T> _exclusive<T>(Future<T> Function() action) async {
    final previous = _tail;
    final finished = Completer<void>();
    _tail = finished.future;
    await previous;
    try {
      return await action();
    } finally {
      finished.complete();
    }
  }

  Future<SyncRunResult> synchronize(String ownerId) =>
      _exclusive(() => _synchronize(ownerId));

  Future<SyncRunResult> _synchronize(String ownerId) async {
    // Work under a deleted quadrant can never be accepted; drop it first.
    await _database.syncOutboxDao.cancelOrphansOfDeletedSectors(ownerId);
    // Operations stored as failed before missing parents became retryable.
    await _database.syncOutboxDao.requeueRecoverable(ownerId);
    final pending = await _database.syncOutboxDao.eligibleBatch(ownerId);
    var pushed = 0;
    var conflictCount = 0;
    if (pending.isNotEmpty) {
      PushResult result;
      try {
        result = await _gateway.push(
          ownerId: ownerId,
          operations: pending
              .where((row) => _registry.supports(row.aggregateType))
              .map(
                (row) => PushMutation(
                  operationId: row.operationId,
                  aggregateType: row.aggregateType,
                  aggregateId: row.aggregateId,
                  kind: row.mutationKind,
                  protocolVersion: row.protocolVersion,
                  payloadSchemaVersion: row.payloadSchemaVersion,
                  baseVersion: row.baseVersion,
                  payloadJson: row.payloadJson,
                  requestHash: row.requestHash,
                  dependsOnOperationId: row.dependencyOperationId,
                ),
              )
              .toList(growable: false),
        );
      } catch (_) {
        for (final row in pending) {
          await _database.syncOutboxDao.restorePending(
            row.operationId,
            'transport_error',
          );
        }
        rethrow;
      }
      final resultById = {
        for (final operation in result.operations)
          operation.operationId: operation,
      };
      final now = DateTime.now().toUtc();
      for (final row in pending) {
        if (!_registry.supports(row.aggregateType)) {
          await _database.syncOutboxDao.markTerminal(
            row.operationId,
            'blocked',
            'unsupported_aggregate',
          );
          continue;
        }
        final operation = resultById[row.operationId];
        if (operation == null) {
          await _database.syncOutboxDao.markPendingRetry(
            row,
            now.add(
              _retryPolicy.delayForAttempt(
                row.attemptCount,
                operationId: row.operationId,
              ),
            ),
            'missing_ack',
          );
        } else if (operation.isAcknowledged) {
          await _database.syncOutboxDao.markDone(row.operationId, now);
          await _database.conflictDao.markResolvedByOperation(row.operationId);
          await _applyAcknowledgement(row, operation, now);
          pushed++;
        } else if (operation.status == PushOperationStatus.conflict) {
          await _database.syncOutboxDao.markTerminal(
            row.operationId,
            'conflict',
            operation.errorCode,
          );
          if (operation.conflict != null) {
            conflictCount += await _recordConflicts(ownerId, [
              operation.conflict!,
            ]);
          }
        } else if (operation.status == PushOperationStatus.rejected &&
            !isRecoverableRejection(operation.errorCode)) {
          await _database.syncOutboxDao.markTerminal(
            row.operationId,
            'failed',
            operation.errorCode,
          );
        } else {
          await _database.syncOutboxDao.markPendingRetry(
            row,
            now.add(
              _retryPolicy.delayForAttempt(
                row.attemptCount,
                operationId: row.operationId,
              ),
            ),
            operation.errorCode ?? 'retryable_error',
          );
        }
      }
    }

    final cursor = await _database.syncCursorDao.read(ownerId, stream);
    final pull = await _gateway.pull(ownerId: ownerId, afterCursor: cursor);
    await _database.transaction(() async {
      await _applyChanges(ownerId, pull.changes);
      conflictCount += await _recordConflicts(ownerId, pull.conflicts);
      await _database.syncCursorDao.write(ownerId, stream, pull.nextCursor);
    });
    return SyncRunResult(
      pushed: pushed,
      pulled: pull.changes.length,
      conflicts: conflictCount,
    );
  }

  /// Read-only remote refresh. Never pushes or clears local work.
  Future<SyncRefreshResult> refresh(String ownerId) => _exclusive(() async {
    final gateway = _gateway;
    if (gateway is! SectorExistenceGateway) {
      throw StateError('remote_refresh_unavailable');
    }
    var pulled = 0;
    while (true) {
      final cursor = await _database.syncCursorDao.read(ownerId, stream);
      final page = await _gateway
          .pull(ownerId: ownerId, afterCursor: cursor)
          .timeout(const Duration(seconds: 30));
      if (page.changes.isNotEmpty && page.nextCursor <= cursor) {
        throw const FormatException('refresh_cursor_not_advancing');
      }
      await _database.transaction(() async {
        for (final change in page.changes) {
          final pending =
              await (_database.select(_database.syncOutbox)
                    ..where(
                      (row) =>
                          row.ownerId.equals(ownerId) &
                          row.aggregateType.equals(change.aggregateType) &
                          row.aggregateId.equals(change.aggregateId) &
                          row.state.equals('done').not(),
                    )
                    ..limit(1))
                  .getSingleOrNull();
          if (pending == null) {
            await _registry
                .require(change.aggregateType)
                .applyRemote(_database, ownerId, change);
          }
        }
        await _recordConflicts(ownerId, page.conflicts);
        await _database.syncCursorDao.write(ownerId, stream, page.nextCursor);
      });
      pulled += page.changes.length;
      if (page.changes.length < 200) break;
    }
    final candidates =
        await (_database.select(_database.sectors)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNotNull() &
                  row.syncState.isIn(const ['synced', 'remote_missing']),
            ))
            .get();
    final ids = candidates.map((row) => row.id).toList();
    final existing = await (gateway as SectorExistenceGateway)
        .existingSectorIds(ownerId: ownerId, candidateIds: ids);
    if (!existing.every(ids.contains)) {
      throw const FormatException('sector_inventory_invalid');
    }
    return _database.transaction(() async {
      final protected = await _hasProtectedWork(ownerId);
      final unavailable = <String>[];
      if (!protected) {
        for (final candidate in candidates) {
          final current =
              await (_database.select(_database.sectors)..where(
                    (row) =>
                        row.ownerId.equals(ownerId) &
                        row.id.equals(candidate.id),
                  ))
                  .getSingleOrNull();
          // A save from another connection while checking the network wins.
          if (current == null ||
              current.deletedAt == null ||
              current.version != candidate.version ||
              current.updatedAt != candidate.updatedAt ||
              current.syncState != candidate.syncState) {
            continue;
          }
          final missing = !existing.contains(candidate.id);
          if (missing) unavailable.add(candidate.id);
          await (_database.update(_database.sectors)..where(
                (row) =>
                    row.ownerId.equals(ownerId) & row.id.equals(candidate.id),
              ))
              .write(
                SectorsCompanion(
                  syncState: Value(missing ? 'remote_missing' : 'synced'),
                ),
              );
        }
      }
      return SyncRefreshResult(
        pulled: pulled,
        unavailableSectorIds: List.unmodifiable(unavailable),
        localChangesProtected: protected,
      );
    });
  });

  Future<bool> _hasProtectedWork(String ownerId) async {
    final pending =
        await (_database.select(_database.syncOutbox)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.state.equals('done').not(),
              )
              ..limit(1))
            .getSingleOrNull();
    if (pending != null) return true;
    final conflict =
        await (_database.select(_database.syncConflicts)
              ..where(
                (row) => row.ownerId.equals(ownerId) & row.resolvedAt.isNull(),
              )
              ..limit(1))
            .getSingleOrNull();
    if (conflict != null) return true;
    final photo =
        await (_database.select(_database.photoAttachments)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.uploadState.equals('done').not(),
              )
              ..limit(1))
            .getSingleOrNull();
    if (photo != null) return true;
    final draft =
        await (_database.select(_database.formDrafts)
              ..where((row) => row.ownerId.equals(ownerId))
              ..limit(1))
            .getSingleOrNull();
    return draft != null;
  }

  Future<void> _applyAcknowledgement(
    SyncOutboxData row,
    PushOperationResult result,
    DateTime acknowledgedAt,
  ) async {
    final newer =
        await (_database.select(_database.syncOutbox)..where(
              (candidate) =>
                  candidate.ownerId.equals(row.ownerId) &
                  candidate.aggregateType.equals(row.aggregateType) &
                  candidate.aggregateId.equals(row.aggregateId) &
                  candidate.operationId.equals(row.operationId).not() &
                  candidate.state.isNotIn(const ['done']),
            ))
            .get();
    if (newer.isNotEmpty) return;
    await _registry
        .require(row.aggregateType)
        .markAcknowledged(
          _database,
          row.ownerId,
          row.aggregateId,
          result.remoteVersion,
          acknowledgedAt,
        );
  }

  Future<void> _applyChanges(String ownerId, List<RemoteChange> changes) async {
    for (final change in changes) {
      await _registry
          .require(change.aggregateType)
          .applyRemote(_database, ownerId, change);
    }
  }

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
          baseJson: Value(conflict.baseJson),
          remoteJson: conflict.remoteJson,
          remoteVersion: Value(conflict.remoteVersion),
          sourceOperationId: Value(conflict.sourceOperationId),
          detectedAt: DateTime.now().toUtc(),
        ),
      );
    }
    return conflicts.length;
  }
}

/// A parent or catalog row that does not exist on the server yet (for example
/// a crop catalog deployed later) is retried with backoff instead of failing
/// for good.
bool isRecoverableRejection(String? errorCode) =>
    errorCode != null && errorCode.endsWith('_missing');
