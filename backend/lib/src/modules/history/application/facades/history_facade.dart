import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/history/domain/entities/history_event.dart';
import 'package:agrocampo_backend/src/modules/history/infrastructure/persistence/history_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final historyFacadeProvider = Provider<HistoryFacade>(
  (ref) => HistoryFacade._(
    HistoryRepository(ref.watch(appDatabaseProvider)),
    ref.watch(historyRefreshActionProvider),
  ),
);

final historyRefreshActionProvider =
    Provider<Future<HistoryRefreshResult> Function(String)>((ref) {
      return (ownerId) async {
        final coordinator = ref.read(syncCoordinatorProvider);
        if (coordinator == null) throw StateError('remote_refresh_unavailable');
        final result = await coordinator.refresh(ownerId);
        return HistoryRefreshResult(
          unavailableSectorIds: result.unavailableSectorIds,
          localChangesProtected: result.localChangesProtected,
        );
      };
    });

final class HistoryFacade {
  HistoryFacade._(this._repository, this._refresh);
  final HistoryRepository _repository;
  final Future<HistoryRefreshResult> Function(String) _refresh;
  Future<HistoryRefreshResult> refresh(String ownerId) => _refresh(ownerId);
  Future<List<HistoryEvent>> list(HistoryFilter filter) =>
      _repository.list(filter);
  Stream<List<HistoryEvent>> watch(HistoryFilter filter) =>
      _repository.watch(filter);
  Stream<List<HistorySector>> watchSectors(String ownerId) =>
      _repository.watchSectors(ownerId);

  /// Export shares the projection without applying the screen's page limit.
  Future<List<HistoryEvent>> listAll(String ownerId) =>
      _repository.listAll(ownerId);
}
