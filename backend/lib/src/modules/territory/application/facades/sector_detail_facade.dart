import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/crop_cycles_api.dart';
import 'package:agrocampo_backend/src/modules/territory/contracts/dto/sector_summary.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/entities/sector.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_summary_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart'
    hide Sector;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sectorDetailFacadeProvider = Provider.autoDispose
    .family<SectorDetailFacade, String>(
      (ref, sectorId) => SectorDetailFacade(
        ref.watch(appDatabaseProvider),
        ref.watch(cropCyclesFacadeProvider),
        sectorId,
      ),
    );

final class SectorDetailFacade {
  const SectorDetailFacade(this._database, this._cropCycles, this.sectorId);

  final AppDatabase _database;
  final CropCyclesFacade _cropCycles;
  final String sectorId;

  Stream<Sector?> watchSector(String ownerId) async* {
    try {
      await _cropCycles.ensureCatalog();
    } on Object {
      // Sector data remains readable if catalog seeding is unavailable.
    }
    yield* SectorRepository(_database)
        .watchById(ownerId: ownerId, sectorId: sectorId);
  }

  Stream<List<SectorSummary>> watchSummaries({
    required String ownerId,
    required String parcelId,
  }) =>
      SectorSummaryRepository(_database)
          .watch(ownerId: ownerId, parcelId: parcelId);
}
