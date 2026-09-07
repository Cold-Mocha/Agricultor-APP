import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/features/history/domain/history_event.dart';
import 'package:agrocampo_backend/features/history/repositories/history_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final historyControllerProvider = Provider<HistoryController>(
  (ref) =>
      HistoryController._(HistoryRepository(ref.watch(appDatabaseProvider))),
);

final class HistoryController {
  HistoryController._(this._repository);
  final HistoryRepository _repository;
  Future<List<HistoryEvent>> list(HistoryFilter filter) =>
      _repository.list(filter);
}
