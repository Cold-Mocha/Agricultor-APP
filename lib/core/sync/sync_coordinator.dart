import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/aggregate_sync_registry.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/core/sync/sync_gateway.dart';
import 'package:agrocampo/core/sync/sync_retry_policy.dart';
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
  SyncCoordinator(
    this._database,
    this._gateway, {
    AggregateSyncRegistry? registry,
    this._retryPolicy = const SyncRetryPolicy(),
  }) : _registry = registry ?? AggregateSyncRegistry(),
       assert(_retryPolicy.baseSeconds > 0);

  static const stream = 'owner-changes-v1';

  final AppDatabase _database;
  final SyncGateway _gateway;
  final AggregateSyncRegistry _registry;
  final SyncRetryPolicy _retryPolicy;

  Future<SyncRunResult> synchronize(String ownerId) async {
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
        } else if (operation.status == PushOperationStatus.rejected) {
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
