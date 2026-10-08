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

  Future<Sector?> loadSector(String ownerId) async {
    try {
      await _cropCycles.ensureCatalog();
    } on Object {
      // Sector data remains readable if catalog seeding is unavailable.
    }
    return SectorRepository(_database)
        .loadById(ownerId: ownerId, sectorId: sectorId);
  }

  Future<void> rename({required String ownerId, required String name}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw StateError('sector_name_required');
    final repository = SectorRepository(_database);
    final sector = await repository.loadById(
      ownerId: ownerId,
      sectorId: sectorId,
    );
    if (sector == null) throw StateError('sector_not_found');
    await repository.saveConfirmed(
      ownerId: ownerId,
      id: sector.id,
      number: sector.number,
      name: trimmed,
      kind: sector.kind,
      polygon: sector.polygon,
      expectedVersion: sector.version,
    );
  }

  /// Soft delete: the tombstone syncs and historical records keep their rows.
  Future<void> delete(String ownerId) =>
      SectorRepository(_database).delete(ownerId: ownerId, id: sectorId);

  Stream<List<SectorSummary>> watchSummaries(String ownerId) =>
      SectorSummaryRepository(_database).watch(ownerId);
}
