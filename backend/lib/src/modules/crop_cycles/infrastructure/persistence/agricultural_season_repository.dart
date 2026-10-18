import 'dart:convert';

import 'package:agrocampo_backend/src/modules/crop_cycles/domain/entities/agricultural_season.dart'
    as domain;
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_request_hash.dart';
import 'package:agrocampo_backend/src/shared/kernel/entity_id.dart';
import 'package:drift/drift.dart';

final class AgriculturalSeasonRepository {
  AgriculturalSeasonRepository(this._database);

  final AppDatabase _database;

  Stream<List<domain.AgriculturalSeason>> watchBySector({
    required String ownerId,
    required String sectorId,
  }) =>
      (_database.select(_database.agriculturalSeasons)
            ..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.sectorId.equals(sectorId) &
                  row.deletedAt.isNull(),
            )
            ..orderBy([(row) => OrderingTerm.desc(row.startsOn)]))
          .watch()
          .map((rows) => rows.map(_toDomain).toList(growable: false));

  Future<String> save({
    required String ownerId,
    required String sectorId,
    required String name,
    required DateTime startsOn,
    required domain.AgriculturalSeasonStatus status,
    String? id,
    DateTime? endsOn,
    String? notes,
  }) async {
    final start = _date(startsOn);
    final end = endsOn == null ? null : _date(endsOn);
    domain.AgriculturalSeason.validate(
      name: name,
      startsOn: start,
      endsOn: end,
      status: status,
    );
    final sector =
        await (_database.select(_database.sectors)..where(
              (row) =>
                  row.id.equals(sectorId) &
                  row.ownerId.equals(ownerId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (sector == null) throw StateError('season_parent_invalid');
    final seasonId = id ?? EntityId.generate().value;
    final existing = id == null
        ? null
        : await (_database.select(_database.agriculturalSeasons)..where(
                (row) =>
                    row.id.equals(id) &
                    row.ownerId.equals(ownerId) &
                    row.sectorId.equals(sectorId),
              ))
              .getSingleOrNull();
    if (id != null && existing == null) throw StateError('season_not_found');
    if (existing != null &&
        !domain.AgriculturalSeason.canTransition(
          domain.AgriculturalSeasonStatus.values.byName(existing.status),
          status,
        )) {
      throw StateError('season_transition_invalid');
    }
    final duplicate = await _database
        .customSelect(
          '''SELECT id FROM agricultural_seasons
         WHERE owner_id = ? AND sector_id = ? AND lower(trim(name)) = lower(trim(?))
           AND id <> ? AND deleted_at IS NULL LIMIT 1''',
          variables: [
            Variable(ownerId),
            Variable(sectorId),
            Variable(name),
            Variable(seasonId),
          ],
        )
        .getSingleOrNull();
    if (duplicate != null) throw StateError('season_name_duplicate');
    if (status == domain.AgriculturalSeasonStatus.active) {
      final other =
          await (_database.select(_database.agriculturalSeasons)..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.sectorId.equals(sectorId) &
                    row.status.equals('active') &
                    row.id.equals(seasonId).not() &
                    row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (other != null) throw StateError('active_season_exists');
    }
    final now = DateTime.now().toUtc();
    final version = (existing?.version ?? 0) + 1;
    final payload = <String, Object?>{
      'id': seasonId,
      'owner_id': ownerId,
      'sector_id': sectorId,
      'name': name.trim(),
      'starts_on': start.toIso8601String(),
      'ends_on': end?.toIso8601String(),
      'status': status.name,
      'notes': notes?.trim(),
      'is_migration_backfill': existing?.isMigrationBackfill ?? false,
      'version': version,
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
    };
    final mutation = existing == null ? 'create' : 'update';
    final operationId = EntityId.generate().value;
    final dependency = await _pendingDependency(
      ownerId: ownerId,
      aggregateType: 'sector',
      aggregateId: sectorId,
    );
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database
          .into(_database.agriculturalSeasons)
          .insertOnConflictUpdate(
            AgriculturalSeasonsCompanion.insert(
              id: seasonId,
              ownerId: ownerId,
              sectorId: sectorId,
              name: name.trim(),
              startsOn: start,
              endsOn: Value(end),
              status: Value(status.name),
              notes: Value(notes?.trim()),
              isMigrationBackfill: Value(
                existing?.isMigrationBackfill ?? false,
              ),
              version: Value(version),
              syncState: const Value('pending'),
              updatedAt: now,
            ),
          ),
      operation: _operation(
        operationId: operationId,
        ownerId: ownerId,
        aggregateId: seasonId,
        mutation: mutation,
        baseVersion: existing?.version,
        payload: payload,
        dependency: dependency,
        createdAt: now,
      ),
    );
    return seasonId;
  }

  Future<void> close({
    required String ownerId,
    required String id,
    required DateTime endsOn,
  }) async {
    final row =
        await (_database.select(_database.agriculturalSeasons)..where(
              (item) => item.id.equals(id) & item.ownerId.equals(ownerId),
            ))
            .getSingle();
    await save(
      ownerId: ownerId,
      sectorId: row.sectorId,
      id: id,
      name: row.name,
      startsOn: row.startsOn,
      endsOn: endsOn,
      status: domain.AgriculturalSeasonStatus.closed,
      notes: row.notes,
    );
  }

  domain.AgriculturalSeason _toDomain(AgriculturalSeason row) =>
      domain.AgriculturalSeason(
        id: row.id,
        ownerId: row.ownerId,
        sectorId: row.sectorId,
        name: row.name,
        startsOn: row.startsOn,
        endsOn: row.endsOn,
        status: domain.AgriculturalSeasonStatus.values.byName(row.status),
        notes: row.notes,
        isMigrationBackfill: row.isMigrationBackfill,
        version: row.version,
        syncState: row.syncState,
        deletedAt: row.deletedAt,
      );

  SyncOutboxCompanion _operation({
    required String operationId,
    required String ownerId,
    required String aggregateId,
    required String mutation,
    required int? baseVersion,
    required Map<String, Object?> payload,
    required String? dependency,
    required DateTime createdAt,
  }) => SyncOutboxCompanion.insert(
    operationId: operationId,
    ownerId: ownerId,
    aggregateType: 'agriculturalSeason',
    aggregateId: aggregateId,
    mutationKind: mutation,
    baseVersion: Value(baseVersion),
    payloadJson: jsonEncode(payload),
    requestHash: Value(
      syncRequestHash(
        aggregateType: 'agriculturalSeason',
        aggregateId: aggregateId,
        mutationKind: mutation,
        baseVersion: baseVersion,
        payload: payload,
      ),
    ),
    dependencyOperationId: Value(dependency),
    createdAt: createdAt,
  );

  Future<String?> _pendingDependency({
    required String ownerId,
    required String aggregateType,
    required String aggregateId,
  }) async {
    final rows =
        await (_database.select(_database.syncOutbox)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.aggregateType.equals(aggregateType) &
                    row.aggregateId.equals(aggregateId) &
                    row.state.isNotIn(const ['done']),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    return rows.isEmpty ? null : rows.first.operationId;
  }

  static DateTime _date(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);
}
