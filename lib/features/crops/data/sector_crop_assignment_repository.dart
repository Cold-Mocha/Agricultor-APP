import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/sync_request_hash.dart';
import 'package:agrocampo/features/crops/domain/crop_ref.dart';
import 'package:agrocampo/features/crops/domain/sector_crop_assignment.dart'
    as domain;
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class SectorCropAssignmentRepository {
  SectorCropAssignmentRepository(this._database);

  final AppDatabase _database;

  Stream<List<domain.SectorCropAssignment>> watchBySector({
    required String ownerId,
    required String sectorId,
  }) =>
      (_database.select(_database.cropSeasons)
            ..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.sectorId.equals(sectorId) &
                  row.deletedAt.isNull(),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.startsOn)]))
          .watch()
          .asyncMap((rows) => Future.wait(rows.map((row) => _toDomain(row))));

  Future<domain.SectorCropAssignment?> activeAt({
    required String ownerId,
    required String sectorId,
    required DateTime instant,
  }) async {
    final rows =
        await (_database.select(_database.cropSeasons)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.sectorId.equals(sectorId) &
                    row.status.equals('active') &
                    row.startsOn.isSmallerOrEqualValue(instant) &
                    (row.endsOn.isNull() |
                        row.endsOn.isBiggerThanValue(instant)) &
                    row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.startsOn)]))
            .get();
    return rows.isEmpty ? null : _toDomain(rows.first);
  }

  Future<List<domain.SectorCropAssignment>> plannedForSeason({
    required String ownerId,
    required String agriculturalSeasonId,
  }) async {
    final rows =
        await (_database.select(_database.cropSeasons)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.agriculturalSeasonId.equals(agriculturalSeasonId) &
                    row.status.equals('planned') &
                    row.deletedAt.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.startsOn)]))
            .get();
    return Future.wait(rows.map(_toDomain));
  }

  Future<String> plan({
    required String ownerId,
    required String sectorId,
    required String agriculturalSeasonId,
    required CropRef crop,
    required DateTime effectiveFrom,
    DateTime? effectiveTo,
    String? notes,
  }) async {
    final start = effectiveFrom.toUtc();
    final end = effectiveTo?.toUtc();
    domain.SectorCropAssignment.validateRange(start, end);
    await _validateContext(
      ownerId: ownerId,
      sectorId: sectorId,
      agriculturalSeasonId: agriculturalSeasonId,
      crop: crop,
      effectiveFrom: start,
      effectiveTo: end,
    );
    final planned =
        await (_database.select(_database.cropSeasons)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.sectorId.equals(sectorId) &
                  row.status.equals('planned') &
                  row.deletedAt.isNull(),
            ))
            .get();
    for (final row in planned) {
      final existing = await _toDomain(row);
      if (existing.overlaps(start, end)) throw StateError('rotation_overlap');
    }
    final id = EntityId.generate().value;
    final now = DateTime.now().toUtc();
    final payload = _payload(
      id: id,
      ownerId: ownerId,
      sectorId: sectorId,
      agriculturalSeasonId: agriculturalSeasonId,
      crop: crop,
      status: domain.SectorCropAssignmentStatus.planned,
      startsOn: start,
      endsOn: end,
      notes: notes,
      version: 1,
      updatedAt: now,
    );
    final dependency = await _latestParentDependency(
      ownerId,
      sectorId,
      agriculturalSeasonId,
      crop,
    );
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database
          .into(_database.cropSeasons)
          .insert(
            CropSeasonsCompanion.insert(
              id: id,
              ownerId: ownerId,
              sectorId: sectorId,
              agriculturalSeasonId: Value(agriculturalSeasonId),
              cropId: crop.id,
              isCustomCrop: Value(crop.isCustom),
              status: const Value('planned'),
              startsOn: start,
              endsOn: Value(end),
              notes: Value(notes?.trim()),
              version: const Value(1),
              syncState: const Value('pending'),
              updatedAt: now,
            ),
          ),
      operation: _operation(
        ownerId: ownerId,
        aggregateId: id,
        mutation: 'create',
        payload: payload,
        dependency: dependency,
        createdAt: now,
      ),
    );
    return id;
  }

  Future<void> activate({
    required String ownerId,
    required String assignmentId,
    required DateTime effectiveAt,
  }) async {
    final target =
        await (_database.select(_database.cropSeasons)..where(
              (row) =>
                  row.id.equals(assignmentId) & row.ownerId.equals(ownerId),
            ))
            .getSingle();
    if (target.status == 'cancelled' || target.status == 'ended') {
      throw StateError('assignment_not_activatable');
    }
    final season =
        await (_database.select(_database.agriculturalSeasons)..where(
              (row) =>
                  row.id.equals(target.agriculturalSeasonId!) &
                  row.ownerId.equals(ownerId) &
                  row.status.equals('active') &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (season == null) throw StateError('assignment_season_not_active');
    final instant = effectiveAt.toUtc();
    if (instant.isBefore(season.startsOn) ||
        (season.endsOn != null && instant.isAfter(season.endsOn!))) {
      throw StateError('assignment_outside_season');
    }
    final current =
        await (_database.select(_database.cropSeasons)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.sectorId.equals(target.sectorId) &
                  row.status.equals('active') &
                  row.id.equals(target.id).not() &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    final now = DateTime.now().toUtc();
    await _database.transaction(() async {
      String? dependency;
      if (current != null) {
        dependency = await _writeStatus(
          current,
          domain.SectorCropAssignmentStatus.ended,
          startsOn: current.startsOn,
          endsOn: instant,
          now: now,
        );
      }
      await _writeStatus(
        target,
        domain.SectorCropAssignmentStatus.active,
        startsOn: instant,
        endsOn: target.endsOn,
        now: now,
        dependency: dependency,
      );
    });
  }

  Future<void> cancel({
    required String ownerId,
    required String assignmentId,
  }) async {
    final row =
        await (_database.select(_database.cropSeasons)..where(
              (item) =>
                  item.id.equals(assignmentId) & item.ownerId.equals(ownerId),
            ))
            .getSingle();
    if (row.status != 'planned') throw StateError('only_planned_can_cancel');
    await _database.transaction(
      () => _writeStatus(
        row,
        domain.SectorCropAssignmentStatus.cancelled,
        startsOn: row.startsOn,
        endsOn: row.endsOn,
        now: DateTime.now().toUtc(),
      ),
    );
  }

  Future<String> _writeStatus(
    CropSeason row,
    domain.SectorCropAssignmentStatus status, {
    required DateTime startsOn,
    required DateTime? endsOn,
    required DateTime now,
    String? dependency,
  }) async {
    final version = row.version + 1;
    final crop = await _resolveCrop(row.cropId, row.isCustomCrop, row.ownerId);
    final payload = _payload(
      id: row.id,
      ownerId: row.ownerId,
      sectorId: row.sectorId,
      agriculturalSeasonId: row.agriculturalSeasonId!,
      crop: crop,
      status: status,
      startsOn: startsOn,
      endsOn: endsOn,
      notes: row.notes,
      version: version,
      updatedAt: now,
    );
    final operationId = EntityId.generate().value;
    final ownDependency = await _pendingAssignmentDependency(row.id);
    if (dependency != null && ownDependency != null) {
      await (_database.update(_database.syncOutbox)
            ..where((operation) => operation.operationId.equals(ownDependency)))
          .write(SyncOutboxCompanion(dependencyOperationId: Value(dependency)));
    }
    await (_database.update(
      _database.cropSeasons,
    )..where((item) => item.id.equals(row.id))).write(
      CropSeasonsCompanion(
        status: Value(status.name),
        startsOn: Value(startsOn),
        endsOn: Value(endsOn),
        version: Value(version),
        syncState: const Value('pending'),
        updatedAt: Value(now),
      ),
    );
    await _database.syncOutboxDao.enqueue(
      _operation(
        operationId: operationId,
        ownerId: row.ownerId,
        aggregateId: row.id,
        mutation: 'update',
        baseVersion: row.version,
        payload: payload,
        dependency: ownDependency ?? dependency,
        createdAt: now,
      ),
    );
    return operationId;
  }

  Future<void> _validateContext({
    required String ownerId,
    required String sectorId,
    required String agriculturalSeasonId,
    required CropRef crop,
    required DateTime effectiveFrom,
    required DateTime? effectiveTo,
  }) async {
    final sector =
        await (_database.select(_database.sectors)..where(
              (row) =>
                  row.id.equals(sectorId) &
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    final season =
        await (_database.select(_database.agriculturalSeasons)..where(
              (row) =>
                  row.id.equals(agriculturalSeasonId) &
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (sector == null ||
        season == null ||
        season.parcelId != sector.parcelId) {
      throw StateError('assignment_context_invalid');
    }
    if (season.status == 'closed') throw StateError('season_closed');
    if (effectiveFrom.isBefore(season.startsOn) ||
        (season.endsOn != null && effectiveFrom.isAfter(season.endsOn!)) ||
        (effectiveTo != null &&
            season.endsOn != null &&
            effectiveTo.isAfter(season.endsOn!))) {
      throw StateError('assignment_outside_season');
    }
    final resolved = await _resolveCrop(crop.id, crop.isCustom, ownerId);
    if (resolved.archived) throw StateError('custom_crop_archived');
  }

  Future<CropRef> _resolveCrop(
    String cropId,
    bool isCustom,
    String ownerId,
  ) async {
    if (isCustom) {
      final row =
          await (_database.select(_database.customCrops)..where(
                (crop) =>
                    crop.id.equals(cropId) &
                    crop.ownerId.equals(ownerId) &
                    crop.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (row == null) throw StateError('custom_crop_not_found');
      return CropRef(
        id: row.id,
        label: row.name,
        source: CropSource.custom,
        archived: row.archivedAt != null,
      );
    }
    final row = await (_database.select(
      _database.officialCrops,
    )..where((crop) => crop.id.equals(cropId))).getSingleOrNull();
    if (row == null) throw StateError('official_crop_not_found');
    return CropRef(
      id: row.id,
      label: row.commonName,
      source: CropSource.official,
      scientificName: row.scientificName,
      category: row.category,
    );
  }

  Future<domain.SectorCropAssignment> _toDomain(CropSeason row) async =>
      domain.SectorCropAssignment(
        id: row.id,
        ownerId: row.ownerId,
        sectorId: row.sectorId,
        agriculturalSeasonId: row.agriculturalSeasonId!,
        crop: await _resolveCrop(row.cropId, row.isCustomCrop, row.ownerId),
        status: domain.SectorCropAssignmentStatus.values.byName(row.status),
        effectiveFrom: row.startsOn,
        effectiveTo: row.endsOn,
        notes: row.notes,
        version: row.version,
        syncState: row.syncState,
        deletedAt: row.deletedAt,
      );

  Map<String, Object?> _payload({
    required String id,
    required String ownerId,
    required String sectorId,
    required String agriculturalSeasonId,
    required CropRef crop,
    required domain.SectorCropAssignmentStatus status,
    required DateTime startsOn,
    required DateTime? endsOn,
    required String? notes,
    required int version,
    required DateTime updatedAt,
  }) => {
    'id': id,
    'owner_id': ownerId,
    'sector_id': sectorId,
    'agricultural_season_id': agriculturalSeasonId,
    'crop_id': crop.id,
    'is_custom_crop': crop.isCustom,
    'status': status.name,
    'starts_on': startsOn.toIso8601String(),
    'ends_on': endsOn?.toIso8601String(),
    'notes': notes?.trim(),
    'version': version,
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': null,
  };

  SyncOutboxCompanion _operation({
    String? operationId,
    required String ownerId,
    required String aggregateId,
    required String mutation,
    int? baseVersion,
    required Map<String, Object?> payload,
    String? dependency,
    required DateTime createdAt,
  }) {
    final id = operationId ?? EntityId.generate().value;
    return SyncOutboxCompanion.insert(
      operationId: id,
      ownerId: ownerId,
      aggregateType: 'sectorCropAssignment',
      aggregateId: aggregateId,
      mutationKind: mutation,
      baseVersion: Value(baseVersion),
      payloadJson: jsonEncode(payload),
      requestHash: Value(
        syncRequestHash(
          aggregateType: 'sectorCropAssignment',
          aggregateId: aggregateId,
          mutationKind: mutation,
          baseVersion: baseVersion,
          payload: payload,
        ),
      ),
      dependencyOperationId: Value(dependency),
      createdAt: createdAt,
    );
  }

  Future<String?> _latestParentDependency(
    String ownerId,
    String sectorId,
    String seasonId,
    CropRef crop,
  ) async {
    final types = <String, String>{
      'sector': sectorId,
      'agriculturalSeason': seasonId,
      if (crop.isCustom) 'customCrop': crop.id,
    };
    final rows =
        await (_database.select(_database.syncOutbox)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.state.isNotIn(const ['done']),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    for (final row in rows) {
      if (types[row.aggregateType] == row.aggregateId) return row.operationId;
    }
    return null;
  }

  Future<String?> _pendingAssignmentDependency(String assignmentId) async {
    final rows =
        await (_database.select(_database.syncOutbox)
              ..where(
                (row) =>
                    row.aggregateType.equals('sectorCropAssignment') &
                    row.aggregateId.equals(assignmentId) &
                    row.state.isNotIn(const ['done']),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    return rows.isEmpty ? null : rows.first.operationId;
  }
}
