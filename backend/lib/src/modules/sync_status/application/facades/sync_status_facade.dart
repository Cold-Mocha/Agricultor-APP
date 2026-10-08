import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/sync_status/contracts/dto/sync_status_summary.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/network/connectivity_service.dart';
import 'package:agrocampo_backend/src/platform/sync/conflicts/conflict_resolver.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_trigger_coordinator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncStatusFacadeProvider = Provider<SyncStatusFacade>(
  (ref) => SyncStatusFacade._(
    ref.watch(appDatabaseProvider),
    () => ref.read(syncTriggerCoordinatorProvider).trigger(SyncTrigger.manual),
  ),
);

final syncConnectivityQueryProvider = Provider<SyncConnectivityQuery>(
  (ref) => SyncConnectivityQuery(ref.watch(connectivityServiceProvider)),
);

final class SyncConnectivityQuery {
  const SyncConnectivityQuery(this._connectivity);

  final ConnectivityService _connectivity;

  Stream<bool> watchOffline() =>
      _connectivity.watch().map((signal) => signal == ConnectionSignal.offline);
}

final class SyncStatusFacade {
  SyncStatusFacade._(this._database, this._requestManualSync);

  final AppDatabase _database;
  final Future<void> Function() _requestManualSync;

  Stream<SyncQueueSummary> watchPending(String ownerId) => _database
      .syncOutboxDao
      .watchPending(ownerId)
      .map(
        (rows) => SyncQueueSummary(
          pending: rows.length,
          retryable: rows.where((row) => row.state == 'retry_wait').length,
          blocked: rows.where((row) => row.state == 'blocked').length,
        ),
      );

  Stream<int> watchPendingCount(String ownerId) =>
      _database.syncOutboxDao.watchPending(ownerId).map((rows) => rows.length);

  Stream<int> watchConflictCount(String ownerId) => _database.conflictDao
      .watchUnresolved(ownerId)
      .map((conflicts) => conflicts.length);

  Future<DateTime?> loadLastConfirmation(String ownerId) async {
    final last =
        await (_database.select(_database.syncOutbox)
              ..where(
                (row) => row.ownerId.equals(ownerId) & row.state.equals('done'),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.completedAt)])
              ..limit(1))
            .getSingleOrNull();
    return last?.completedAt;
  }

  Future<void> retry(String ownerId) async {
    final rows = await _database.syncOutboxDao.watchPending(ownerId).first;
    for (final row in rows.where((row) => row.state == 'retry_wait')) {
      await _database.syncOutboxDao.retryManually(ownerId, row.operationId);
    }
    await _requestManualSync();
  }

  Future<ConflictComparison?> loadConflict(String conflictId) async {
    final conflict = await (_database.select(
      _database.syncConflicts,
    )..where((row) => row.conflictId.equals(conflictId))).getSingleOrNull();
    if (conflict == null) return null;
    return ConflictComparison(
      localDescription: conflict.localJson,
      remoteDescription: conflict.remoteJson,
    );
  }

  Future<void> keepLocalVersion(String conflictId) =>
      ConflictResolver(_database).resolve(conflictId, ConflictChoice.keepLocal);

  Future<void> useBackedUpVersion(String conflictId) =>
      ConflictResolver(_database)
          .resolve(conflictId, ConflictChoice.keepRemote);
}
