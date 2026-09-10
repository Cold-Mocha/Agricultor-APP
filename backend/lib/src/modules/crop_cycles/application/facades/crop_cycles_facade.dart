import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/domain/entities/agricultural_season.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/domain/entities/crop_ref.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/domain/entities/sector_crop_assignment.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/agricultural_season_repository.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/crop_exchange_repository.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/crop_repository.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/crop_seed_loader.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/sector_crop_assignment_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart'
    as db;
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cropCyclesFacadeProvider = Provider<CropCyclesFacade>(
  (ref) => CropCyclesFacade._(ref.watch(appDatabaseProvider)),
);

final class CustomCropFormInput {
  const CustomCropFormInput({required this.name, this.notes, this.id});
  final String name;
  final String? notes;
  final String? id;
}

final class SeasonFormInput {
  const SeasonFormInput({
    required this.parcelId,
    required this.name,
    required this.startsOn,
    required this.status,
    this.id,
    this.endsOn,
    this.notes,
  });
  final String parcelId;
  final String name;
  final DateTime startsOn;
  final AgriculturalSeasonStatus status;
  final String? id;
  final DateTime? endsOn;
  final String? notes;
}

final class CropPlanOptions {
  const CropPlanOptions({required this.season, required this.crops});
  final AgriculturalSeason season;
  final List<CropRef> crops;
}

final class CropExchangeOption {
  const CropExchangeOption({required this.id, required this.name});
  final String id;
  final String name;
}

/// Application operations for catalog, seasons and dated crop assignments.
/// Presentation follows master.md Screens, Navigation, States and Offline UX.
final class CropCyclesFacade {
  CropCyclesFacade._(this._database);
  final db.AppDatabase _database;

  Future<void> ensureCatalog() => CropSeedLoader(_database).seedIfEmpty();

  Stream<List<CropRef>> watchCatalog(String ownerId, {String query = ''}) {
    final normalized = CropRepository.normalizeName(query);
    return CropRepository(_database)
        .watchCatalog(ownerId)
        .map(
          (crops) => crops
              .where(
                (crop) =>
                    normalized.isEmpty ||
                    CropRepository.normalizeName(crop.label)
                        .contains(normalized),
              )
              .toList(growable: false),
        );
  }

  Future<String> saveCustom({
    required String ownerId,
    required CustomCropFormInput input,
  }) => CropRepository(_database).saveCustom(
    ownerId: ownerId,
    id: input.id,
    name: input.name,
    notes: input.notes,
  );

  Future<void> archiveCustom({
    required String ownerId,
    required String id,
    required bool archived,
  }) =>
      CropRepository(_database)
          .archiveCustom(ownerId: ownerId, id: id, archived: archived);

  Stream<List<AgriculturalSeason>> watchSeasons({
    required String ownerId,
    required String parcelId,
  }) =>
      AgriculturalSeasonRepository(_database)
          .watchByParcel(ownerId: ownerId, parcelId: parcelId);

  Future<AgriculturalSeason?> loadSeason({
    required String ownerId,
    required String id,
  }) async {
    final row =
        await (_database.select(_database.agriculturalSeasons)..where(
              (row) =>
                  row.id.equals(id) &
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return row == null ? null : _season(row);
  }

  Future<String> saveSeason({
    required String ownerId,
    required SeasonFormInput input,
  }) => AgriculturalSeasonRepository(_database).save(
    ownerId: ownerId,
    parcelId: input.parcelId,
    id: input.id,
    name: input.name,
    startsOn: input.startsOn,
    endsOn: input.endsOn,
    status: input.status,
    notes: input.notes,
  );

  Stream<List<SectorCropAssignment>> watchAssignments({
    required String ownerId,
    required String sectorId,
  }) =>
      SectorCropAssignmentRepository(_database)
          .watchBySector(ownerId: ownerId, sectorId: sectorId);

  Future<SectorCropAssignment?> loadAssignment({
    required String ownerId,
    required String id,
  }) =>
      SectorCropAssignmentRepository(_database).load(ownerId: ownerId, id: id);

  Future<void> activate({
    required String ownerId,
    required String assignmentId,
    required DateTime effectiveAt,
  }) => SectorCropAssignmentRepository(_database).activate(
    ownerId: ownerId,
    assignmentId: assignmentId,
    effectiveAt: effectiveAt,
  );

  Future<void> cancel({
    required String ownerId,
    required String assignmentId,
  }) =>
      SectorCropAssignmentRepository(_database)
          .cancel(ownerId: ownerId, assignmentId: assignmentId);

  Future<CropPlanOptions?> planOptions({
    required String ownerId,
    required String sectorId,
  }) async {
    await ensureCatalog();
    final sector =
        await (_database.select(_database.sectors)..where(
              (row) =>
                  row.id.equals(sectorId) &
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull(),
            ))
            .getSingle();
    if (sector.kind != 'crop') throw StateError('operation_requires_crop');
    final season =
        await (_database.select(_database.agriculturalSeasons)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.parcelId.equals(sector.parcelId) &
                  row.status.equals('active') &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (season == null) return null;
    final crops = (await CropRepository(_database).watchCatalog(ownerId).first)
        .where((crop) => !crop.archived)
        .toList(growable: false);
    return CropPlanOptions(season: _season(season), crops: crops);
  }

  Future<String> plan({
    required String ownerId,
    required String sectorId,
    required String agriculturalSeasonId,
    required CropRef crop,
    required DateTime effectiveFrom,
  }) => SectorCropAssignmentRepository(_database).plan(
    ownerId: ownerId,
    sectorId: sectorId,
    agriculturalSeasonId: agriculturalSeasonId,
    crop: crop,
    effectiveFrom: effectiveFrom,
  );

  Future<List<CropExchangeOption>> exchangeOptions({
    required String ownerId,
    required String sectorId,
  }) async {
    final sector =
        await (_database.select(_database.sectors)..where(
              (row) =>
                  row.id.equals(sectorId) &
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull(),
            ))
            .getSingle();
    final alternatives =
        await (_database.select(_database.sectors)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.parcelId.equals(sector.parcelId) &
                  row.id.equals(sectorId).not() &
                  row.deletedAt.isNull(),
            ))
            .get();
    return alternatives
        .map((row) => CropExchangeOption(id: row.id, name: row.name))
        .toList(growable: false);
  }

  Future<void> exchange({
    required String ownerId,
    required String firstSectorId,
    required String secondSectorId,
    required DateTime effectiveAt,
  }) async {
    await CropExchangeRepository(_database).exchange(
      ownerId: ownerId,
      firstSectorId: firstSectorId,
      secondSectorId: secondSectorId,
      effectiveAt: effectiveAt,
    );
  }

  AgriculturalSeason _season(db.AgriculturalSeason row) => AgriculturalSeason(
    id: row.id,
    ownerId: row.ownerId,
    parcelId: row.parcelId,
    name: row.name,
    startsOn: row.startsOn,
    endsOn: row.endsOn,
    status: AgriculturalSeasonStatus.values.byName(row.status),
    notes: row.notes,
    isMigrationBackfill: row.isMigrationBackfill,
    version: row.version,
    syncState: row.syncState,
    deletedAt: row.deletedAt,
  );
}
