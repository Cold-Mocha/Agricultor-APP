import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/crop_cycles_api.dart';
import 'package:agrocampo_backend/src/modules/history/history_api.dart';
import 'package:agrocampo_backend/src/modules/territory/contracts/dto/sector_summary.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_summary_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sectorListFacadeProvider = Provider.autoDispose<SectorListFacade>(
  (ref) => SectorListFacade(
    ref.watch(appDatabaseProvider),
    ref.watch(cropCyclesFacadeProvider),
    ref.watch(historyFacadeProvider),
  ),
);

final class SectorListFacade {
  const SectorListFacade(this._database, this._cropCycles, this._history);

  final AppDatabase _database;
  final CropCyclesFacade _cropCycles;
  final HistoryFacade _history;

  Stream<List<SectorSummary>> watchSummaries(String ownerId) async* {
    try {
      await _cropCycles.ensureCatalog();
    } on Object {
      // The local sector projection remains usable without the seed.
    }
    yield* SectorSummaryRepository(_database).watch(ownerId);
  }

  Future<List<HistoryEvent>> recentHistory(String ownerId) =>
      _history.list(HistoryFilter(ownerId: ownerId, limit: 3));
}
