import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/history/domain/entities/history_event.dart';
import 'package:agrocampo_backend/src/modules/history/infrastructure/persistence/history_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final historyFacadeProvider = Provider<HistoryFacade>(
  (ref) => HistoryFacade._(HistoryRepository(ref.watch(appDatabaseProvider))),
);

final class HistoryFacade {
  HistoryFacade._(this._repository);
  final HistoryRepository _repository;
  Future<List<HistoryEvent>> list(HistoryFilter filter) =>
      _repository.list(filter);
}
