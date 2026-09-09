import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/sync_status_ui_state.dart';

export '../state/sync_status_ui_state.dart';

final syncStatusControllerProvider = Provider<SyncStatusController>(
  (ref) => SyncStatusController(ref.watch(syncStatusFacadeProvider)),
);

final pendingSyncCountProvider = StreamProvider.autoDispose.family<int, String>(
  (ref, ownerId) =>
      ref.watch(syncStatusControllerProvider).watchPendingCount(ownerId),
);

final offlineStatusProvider = StreamProvider.autoDispose<bool>(
  (ref) => ref.watch(syncConnectivityQueryProvider).watchOffline(),
);

final class SyncStatusController {
  const SyncStatusController(this._facade);

  final SyncStatusFacade _facade;

  Stream<SyncStatusUiState> watchPending(String ownerId) =>
      _facade.watchPending(ownerId).map(SyncStatusUiState.fromSummary);

  Stream<int> watchPendingCount(String ownerId) =>
      _facade.watchPendingCount(ownerId);

  Stream<int> watchConflictCount(String ownerId) =>
      _facade.watchConflictCount(ownerId);

  Future<DateTime?> loadLastConfirmation(String ownerId) =>
      _facade.loadLastConfirmation(ownerId);

  Future<void> retry(String ownerId) => _facade.retry(ownerId);

  Future<ConflictComparisonUiState?> loadConflict(String conflictId) async {
    final comparison = await _facade.loadConflict(conflictId);
    return comparison == null
        ? null
        : ConflictComparisonUiState.fromContract(comparison);
  }

  Future<void> keepLocalVersion(String conflictId) =>
      _facade.keepLocalVersion(conflictId);

  Future<void> useBackedUpVersion(String conflictId) =>
      _facade.useBackedUpVersion(conflictId);
}
