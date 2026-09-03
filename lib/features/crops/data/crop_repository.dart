import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/sync_request_hash.dart';
import 'package:agrocampo/features/crops/data/sector_crop_assignment_repository.dart';
import 'package:agrocampo/features/crops/domain/crop_ref.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class CropRepository {
  CropRepository(this._database);

  final AppDatabase _database;

  Stream<List<CropRef>> watchCatalog(String ownerId) => _database
      .customSelect(
        '''
        SELECT id, common_name AS label, scientific_name, category,
               icon_asset, color_token,
               'official' AS source, 0 AS archived
        FROM official_crops
        UNION ALL
        SELECT id, name AS label, NULL AS scientific_name, 'personalizado' AS category,
               NULL AS icon_asset, NULL AS color_token,
               'custom' AS source, CASE WHEN archived_at IS NULL THEN 0 ELSE 1 END AS archived
        FROM custom_crops
        WHERE owner_id = ? AND deleted_at IS NULL
        ORDER BY label COLLATE NOCASE
        ''',
        variables: [Variable(ownerId)],
        readsFrom: {_database.officialCrops, _database.customCrops},
      )
      .watch()
      .map(
        (rows) => rows
            .map(
              (row) => CropRef(
                id: row.read<String>('id'),
                label: row.read<String>('label'),
                source: row.read<String>('source') == 'custom'
                    ? CropSource.custom
                    : CropSource.official,
                scientificName: row.readNullable<String>('scientific_name'),
                category: row.readNullable<String>('category'),
                iconAsset: row.readNullable<String>('icon_asset'),
                colorToken: row.readNullable<String>('color_token'),
                archived: row.read<int>('archived') == 1,
              ),
            )
            .toList(growable: false),
      );

  Future<CropRef> getById({
    required String ownerId,
    required String cropId,
    required bool isCustom,
  }) async {
    if (isCustom) {
      final row =
          await (_database.select(_database.customCrops)..where(
                (crop) =>
                    crop.ownerId.equals(ownerId) &
                    crop.id.equals(cropId) &
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
      iconAsset: row.iconAsset,
      colorToken: row.colorToken,
    );
  }

  Future<String> createCustom({
    required String ownerId,
    required String name,
    String? description,
    String? notes,
  }) => saveCustom(
    ownerId: ownerId,
    name: name,
    description: description,
    notes: notes,
  );

  Future<String> saveCustom({
    required String ownerId,
    required String name,
    String? id,
    String? description,
    String? notes,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 120) {
      throw ArgumentError.value(name, 'name', 'custom_crop_name_invalid');
    }
    final normalized = normalizeName(trimmed);
    final cropId = id ?? EntityId.generate().value;
    final existing = id == null
        ? null
        : await (_database.select(_database.customCrops)..where(
                (row) => row.id.equals(id) & row.ownerId.equals(ownerId),
              ))
              .getSingleOrNull();
    if (id != null && existing == null) {
      throw StateError('custom_crop_not_found');
    }
    final duplicate =
        await (_database.select(_database.customCrops)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.normalizedName.equals(normalized) &
                  row.id.equals(cropId).not() &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (duplicate != null) throw StateError('custom_crop_name_duplicate');
    final now = DateTime.now().toUtc();
    final version = (existing?.version ?? 0) + 1;
    final payload = <String, Object?>{
      'id': cropId,
      'owner_id': ownerId,
      'name': trimmed,
      'normalized_name': normalized,
      'description': description?.trim(),
      'notes': notes?.trim(),
      'archived_at': existing?.archivedAt?.toIso8601String(),
      'version': version,
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
    };
    final mutation = existing == null ? 'create' : 'update';
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database
          .into(_database.customCrops)
          .insertOnConflictUpdate(
            CustomCropsCompanion.insert(
              id: cropId,
              ownerId: ownerId,
              name: trimmed,
              normalizedName: Value(normalized),
              description: Value(description?.trim()),
              notes: Value(notes?.trim()),
              archivedAt: Value(existing?.archivedAt),
              version: Value(version),
              syncState: const Value('pending'),
              updatedAt: now,
            ),
          ),
      operation: _operation(
        ownerId: ownerId,
        aggregateId: cropId,
        mutation: mutation,
        baseVersion: existing?.version,
        payload: payload,
        createdAt: now,
      ),
    );
    return cropId;
  }

  Future<void> archiveCustom({
    required String ownerId,
    required String id,
    required bool archived,
  }) async {
    final row =
        await (_database.select(_database.customCrops)..where(
              (crop) => crop.id.equals(id) & crop.ownerId.equals(ownerId),
            ))
            .getSingle();
    final now = DateTime.now().toUtc();
    final archivedAt = archived ? now : null;
    final version = row.version + 1;
    final payload = <String, Object?>{
      'id': row.id,
      'owner_id': row.ownerId,
      'name': row.name,
      'normalized_name': row.normalizedName,
      'description': row.description,
      'notes': row.notes,
      'archived_at': archivedAt?.toIso8601String(),
      'version': version,
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
    };
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () =>
          (_database.update(
            _database.customCrops,
          )..where((crop) => crop.id.equals(id))).write(
            CustomCropsCompanion(
              archivedAt: Value(archivedAt),
              version: Value(version),
              syncState: const Value('pending'),
              updatedAt: Value(now),
            ),
          ),
      operation: _operation(
        ownerId: ownerId,
        aggregateId: id,
        mutation: archived ? 'archive' : 'update',
        baseVersion: row.version,
        payload: payload,
        createdAt: now,
      ),
    );
  }

  Future<String> planRotation({
    required String ownerId,
    required String sectorId,
    required String cropId,
    required DateTime startsOn,
    DateTime? endsOn,
    bool isCustomCrop = false,
    String? agriculturalSeasonId,
  }) async {
    final sector =
        await (_database.select(_database.sectors)..where(
              (row) => row.id.equals(sectorId) & row.ownerId.equals(ownerId),
            ))
            .getSingle();
    final seasonId =
        agriculturalSeasonId ??
        (await (_database.select(_database.agriculturalSeasons)..where(
                  (row) =>
                      row.ownerId.equals(ownerId) &
                      row.parcelId.equals(sector.parcelId) &
                      row.status.equals('active') &
                      row.deletedAt.isNull(),
                ))
                .getSingleOrNull())
            ?.id;
    if (seasonId == null) throw StateError('active_season_required');
    final crop = await getById(
      ownerId: ownerId,
      cropId: cropId,
      isCustom: isCustomCrop,
    );
    return SectorCropAssignmentRepository(_database).plan(
      ownerId: ownerId,
      sectorId: sectorId,
      agriculturalSeasonId: seasonId,
      crop: crop,
      effectiveFrom: startsOn,
      effectiveTo: endsOn,
    );
  }

  Future<void> activate(String assignmentId, {DateTime? effectiveAt}) async {
    final row = await (_database.select(
      _database.cropSeasons,
    )..where((item) => item.id.equals(assignmentId))).getSingle();
    await SectorCropAssignmentRepository(_database).activate(
      ownerId: row.ownerId,
      assignmentId: assignmentId,
      effectiveAt: effectiveAt ?? row.startsOn,
    );
  }

  SyncOutboxCompanion _operation({
    required String ownerId,
    required String aggregateId,
    required String mutation,
    required int? baseVersion,
    required Map<String, Object?> payload,
    required DateTime createdAt,
  }) => SyncOutboxCompanion.insert(
    operationId: EntityId.generate().value,
    ownerId: ownerId,
    aggregateType: 'customCrop',
    aggregateId: aggregateId,
    mutationKind: mutation,
    baseVersion: Value(baseVersion),
    payloadJson: jsonEncode(payload),
    requestHash: Value(
      syncRequestHash(
        aggregateType: 'customCrop',
        aggregateId: aggregateId,
        mutationKind: mutation,
        baseVersion: baseVersion,
        payload: payload,
      ),
    ),
    createdAt: createdAt,
  );

  static String normalizeName(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[áàäâ]'), 'a')
      .replaceAll(RegExp(r'[éèëê]'), 'e')
      .replaceAll(RegExp(r'[íìïî]'), 'i')
      .replaceAll(RegExp(r'[óòöô]'), 'o')
      .replaceAll(RegExp(r'[úùüû]'), 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'\s+'), ' ');
}
