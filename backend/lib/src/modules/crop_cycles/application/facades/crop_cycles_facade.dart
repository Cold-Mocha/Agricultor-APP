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
    required this.sectorId,
    required this.name,
    required this.startsOn,
    required this.status,
    this.id,
    this.endsOn,
    this.notes,
  });
  final String sectorId;
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
    required String sectorId,
  }) =>
      AgriculturalSeasonRepository(_database)
          .watchBySector(ownerId: ownerId, sectorId: sectorId);

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
    sectorId: input.sectorId,
    id: input.id,
    name: input.name,
    startsOn: input.startsOn,
    endsOn: input.endsOn,
    status: input.status,
    notes: input.notes,
  );

  /// Saves a season from its dates only: the status follows today's date and
  /// the name is the date range, so the farmer edits start, end and notes.
  Future<String> saveSeasonByDates({
    required String ownerId,
    required String sectorId,
    required DateTime startsOn,
    required DateTime endsOn,
    String? id,
    String? notes,
    DateTime? today,
  }) {
    String date(DateTime value) =>
        '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
    return AgriculturalSeasonRepository(_database).save(
      ownerId: ownerId,
      sectorId: sectorId,
      id: id,
      name: 'Temporada ${date(startsOn)} – ${date(endsOn)}',
      startsOn: startsOn,
      endsOn: endsOn,
      status: AgriculturalSeason.statusFor(
        startsOn: startsOn,
        endsOn: endsOn,
        today: today ?? DateTime.now(),
      ),
      notes: notes,
    );
  }

  /// Moves seasons forward as days pass: planned ones start and active ones
  /// close on their dates. A closed season never reopens.
  Future<int> reconcileSeasonStatuses(String ownerId, {DateTime? today}) async {
    final rows =
        await (_database.select(_database.agriculturalSeasons)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull() &
                  row.endsOn.isNotNull() &
                  row.status.isIn(const ['planned', 'active']),
            ))
            .get();
    var changed = 0;
    for (final row in rows) {
      final current = AgriculturalSeasonStatus.values.byName(row.status);
      final next = AgriculturalSeason.statusFor(
        startsOn: row.startsOn,
        endsOn: row.endsOn!,
        today: today ?? DateTime.now(),
      );
      if (next == current || !AgriculturalSeason.canTransition(current, next)) {
        continue;
      }
      try {
        await AgriculturalSeasonRepository(_database).save(
          ownerId: ownerId,
          sectorId: row.sectorId,
          id: row.id,
          name: row.name,
          startsOn: row.startsOn,
          endsOn: row.endsOn,
          status: next,
          notes: row.notes,
        );
        changed++;
      } on StateError {
        // Another season is already active in this quadrant; leave it.
      }
    }
    return changed;
  }

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

  Future<void> end({
    required String ownerId,
    required String assignmentId,
    required DateTime effectiveAt,
  }) => SectorCropAssignmentRepository(
    _database,
  ).end(ownerId: ownerId, assignmentId: assignmentId, effectiveAt: effectiveAt);

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
                  row.sectorId.equals(sector.id) &
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

  /// Plans and activates [crop] in one step so it becomes the sector's current
  /// crop from [effectiveFrom].
  Future<String> assign({
    required String ownerId,
    required String sectorId,
    required String agriculturalSeasonId,
    required CropRef crop,
    required DateTime effectiveFrom,
  }) => _database.transaction(() async {
    final assignmentId = await SectorCropAssignmentRepository(_database).plan(
      ownerId: ownerId,
      sectorId: sectorId,
      agriculturalSeasonId: agriculturalSeasonId,
      crop: crop,
      effectiveFrom: effectiveFrom,
    );
    await activate(
      ownerId: ownerId,
      assignmentId: assignmentId,
      effectiveAt: effectiveFrom,
    );
    return assignmentId;
  });

  /// Sets [crop] for a season just configured. In a running season it
  /// replaces the current crop from today; in a future one it starts with the
  /// season and becomes current on that date.
  Future<String> assignCropForSeason({
    required String ownerId,
    required String sectorId,
    required String agriculturalSeasonId,
    required CropRef crop,
    DateTime? today,
  }) async {
    final season =
        await (_database.select(_database.agriculturalSeasons)..where(
              (row) =>
                  row.id.equals(agriculturalSeasonId) &
                  row.ownerId.equals(ownerId) &
                  row.sectorId.equals(sectorId) &
                  row.deletedAt.isNull(),
            ))
            .getSingle();
    return switch (season.status) {
      'active' => assign(
        ownerId: ownerId,
        sectorId: sectorId,
        agriculturalSeasonId: season.id,
        crop: crop,
        effectiveFrom: _laterOf(today ?? DateTime.now(), season.startsOn),
      ),
      'planned' => SectorCropAssignmentRepository(_database).plan(
        ownerId: ownerId,
        sectorId: sectorId,
        agriculturalSeasonId: season.id,
        crop: crop,
        effectiveFrom: season.startsOn,
      ),
      _ => throw StateError('season_closed'),
    };
  }

  static DateTime _laterOf(DateTime a, DateTime b) => a.isAfter(b) ? a : b;

  /// Non-archived crops a farmer can pick for a quadrant.
  Future<List<CropRef>> availableCrops(String ownerId) async {
    await ensureCatalog();
    return (await CropRepository(_database).watchCatalog(ownerId).first)
        .where((crop) => !crop.archived)
        .toList(growable: false);
  }

  /// First crop of a new quadrant. Seasons belong to one quadrant, so when it
  /// has no active season a `Temporada {año}` starting today is opened first.
  Future<String> assignInitialCrop({
    required String ownerId,
    required String sectorId,
    required CropRef crop,
    DateTime? effectiveFrom,
  }) {
    final start = effectiveFrom ?? DateTime.now();
    return _database.transaction(() async {
      final active =
          await (_database.select(_database.agriculturalSeasons)..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.sectorId.equals(sectorId) &
                    row.status.equals('active') &
                    row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      final seasonId =
          active?.id ??
          await AgriculturalSeasonRepository(_database).save(
            ownerId: ownerId,
            sectorId: sectorId,
            name: 'Temporada ${start.year}',
            startsOn: start,
            status: AgriculturalSeasonStatus.active,
          );
      return assign(
        ownerId: ownerId,
        sectorId: sectorId,
        agriculturalSeasonId: seasonId,
        crop: crop,
        effectiveFrom: start,
      );
    });
  }

  Future<List<CropExchangeOption>> exchangeOptions({
    required String ownerId,
    required String sectorId,
  }) async {
    // Fails fast when the source sector is missing or foreign.
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
                  row.kind.equals('crop') &
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
    sectorId: row.sectorId,
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
