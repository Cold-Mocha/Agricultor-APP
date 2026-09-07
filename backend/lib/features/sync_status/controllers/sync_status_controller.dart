import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/core/database/app_database.dart';
import 'package:agrocampo_backend/core/network/connectivity_service.dart';
import 'package:agrocampo_backend/core/sync/conflicts/conflict_resolver.dart';
import 'package:agrocampo_backend/core/sync/sync_trigger_coordinator.dart';
import 'package:agrocampo_backend/features/sync_status/dto/sync_status_ui_state.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingSyncCountProvider = StreamProvider.autoDispose.family<int, String>(
  (ref, ownerId) => ref
      .watch(appDatabaseProvider)
      .syncOutboxDao
      .watchPending(ownerId)
      .map((rows) => rows.length),
);

final offlineStatusProvider = StreamProvider.autoDispose<bool>(
  (ref) => ref
      .watch(connectivityServiceProvider)
      .watch()
      .map((signal) => signal == ConnectionSignal.offline),
);

final syncStatusControllerProvider = Provider<SyncStatusController>(
  (ref) => SyncStatusController._(
    ref.watch(appDatabaseProvider),
    () => ref.read(syncTriggerCoordinatorProvider).trigger(SyncTrigger.manual),
  ),
);

final class SyncStatusController {
  SyncStatusController._(this._database, this._requestManualSync);

  final AppDatabase _database;
  final Future<void> Function() _requestManualSync;

  Stream<SyncStatusUiState> watchPending(String ownerId) => _database
      .syncOutboxDao
      .watchPending(ownerId)
      .map(
        (rows) => SyncStatusUiState(
          pending: rows.length,
          retryable: rows.where((row) => row.state == 'retry_wait').length,
          blocked: rows.where((row) => row.state == 'blocked').length,
        ),
      );

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

  Future<ConflictComparisonUiState?> loadConflict(String conflictId) async {
    final conflict = await (_database.select(
      _database.syncConflicts,
    )..where((row) => row.conflictId.equals(conflictId))).getSingleOrNull();
    if (conflict == null) return null;
    return ConflictComparisonUiState(
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
