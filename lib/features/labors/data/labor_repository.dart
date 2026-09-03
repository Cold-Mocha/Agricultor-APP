import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/sync_request_hash.dart';
import 'package:agrocampo/features/labors/domain/labor_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class LaborRepository {
  LaborRepository(this._database);

  final AppDatabase _database;

  Future<String> save({
    required String ownerId,
    required String parcelId,
    required String sectorId,
    required LaborType type,
    required DateTime occurredAt,
    LaborDetails? details,
    String? id,
    String? seasonId,
    String? cropAssignmentId,
    String? customName,
    String? notes,
    String? supersedesLaborId,
  }) async {
    final effectiveDetails =
        details ??
        (type == LaborType.other
            ? LaborDetails.current(type, {
                'name': customName?.trim(),
                'description': notes?.trim(),
              })
            : type == LaborType.soil || type == LaborType.apiary
            ? LaborDetails.current(type, const {})
            : throw ArgumentError('labor_details_required'));
    if (effectiveDetails.type != type || effectiveDetails.schemaVersion <= 0) {
      throw ArgumentError('labor_details_type_mismatch');
    }
    if (type == LaborType.other &&
        (customName == null ||
            customName.trim().isEmpty ||
            notes == null ||
            notes.trim().isEmpty)) {
      throw ArgumentError('other_labor_requires_name_and_notes');
    }
    final instant = occurredAt.toUtc();
    final context = await resolveContext(
      ownerId: ownerId,
      parcelId: parcelId,
      sectorId: sectorId,
      occurredAt: instant,
      seasonId: seasonId,
      cropAssignmentId: cropAssignmentId,
      correction: supersedesLaborId != null,
    );
    final laborId = id ?? EntityId.generate().value;
    final existing =
        await (_database.select(_database.labors)..where(
              (row) => row.id.equals(laborId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (existing != null) return existing.id;
    final now = DateTime.now().toUtc();
    final payload = <String, Object?>{
      'id': laborId,
      'owner_id': ownerId,
      'parcel_id': context.parcelId,
      'sector_id': context.sectorId,
      'agricultural_season_id': context.seasonId,
      'crop_assignment_id': context.assignmentId,
      'type': type.name,
      'custom_name': customName?.trim(),
      'details': effectiveDetails.toJson(),
      'details_schema_version': effectiveDetails.schemaVersion,
      'status': 'recorded',
      'supersedes_labor_id': supersedesLaborId,
      'notes': notes?.trim(),
      'occurred_at': instant.toIso8601String(),
      'version': 1,
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
    };
    final dependency = await _pendingDependency(
      ownerId,
      'sectorCropAssignment',
      context.assignmentId,
    );
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database
          .into(_database.labors)
          .insert(
            LaborsCompanion.insert(
              id: laborId,
              ownerId: ownerId,
              parcelId: context.parcelId,
              sectorId: context.sectorId,
              seasonId: Value(context.seasonId),
              cropAssignmentId: Value(context.assignmentId),
              type: type.name,
              customName: Value(customName?.trim()),
              detailsJson: Value(effectiveDetails.encode()),
              detailsSchemaVersion: Value(effectiveDetails.schemaVersion),
              status: const Value('recorded'),
              supersedesLaborId: Value(supersedesLaborId),
              notes: Value(notes?.trim()),
              occurredAt: instant,
              version: const Value(1),
              syncState: const Value('pending'),
              updatedAt: now,
            ),
          ),
      operation: _operation(
        ownerId: ownerId,
        aggregateId: laborId,
        mutation: 'create',
        payload: payload,
        dependency: dependency,
        createdAt: now,
      ),
    );
    await _database.formDraftDao.clear(ownerId, 'labor');
    return laborId;
  }

  Future<String> correct({
    required String ownerId,
    required String originalLaborId,
    required LaborDetails details,
    DateTime? occurredAt,
    String? notes,
    String? customName,
  }) async {
    final original =
        await (_database.select(_database.labors)..where(
              (row) =>
                  row.id.equals(originalLaborId) & row.ownerId.equals(ownerId),
            ))
            .getSingle();
    if (original.status == 'voided') throw StateError('labor_already_voided');
    return _database.transaction(() async {
      final replacementId = await save(
        ownerId: ownerId,
        parcelId: original.parcelId,
        sectorId: original.sectorId,
        seasonId: original.seasonId,
        cropAssignmentId: original.cropAssignmentId,
        type: LaborType.values.byName(original.type),
        occurredAt: occurredAt ?? original.occurredAt,
        details: details,
        customName: customName ?? original.customName,
        notes: notes ?? original.notes,
        supersedesLaborId: original.id,
      );
      await _markStatus(original, 'corrected');
      return replacementId;
    });
  }

  Future<void> voidLabor({
    required String ownerId,
    required String laborId,
  }) async {
    final row =
        await (_database.select(_database.labors)..where(
              (labor) =>
                  labor.id.equals(laborId) & labor.ownerId.equals(ownerId),
            ))
            .getSingle();
    await _database.transaction(() => _markStatus(row, 'voided'));
  }

  Future<LaborContext> resolveContext({
    required String ownerId,
    required String parcelId,
    required String sectorId,
    required DateTime occurredAt,
    String? seasonId,
    String? cropAssignmentId,
    bool correction = false,
  }) async {
    final sector =
        await (_database.select(_database.sectors)..where(
              (row) =>
                  row.id.equals(sectorId) &
                  row.ownerId.equals(ownerId) &
                  row.parcelId.equals(parcelId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (sector == null) throw StateError('labor_sector_context_invalid');
    final assignments =
        await (_database.select(_database.cropSeasons)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.sectorId.equals(sectorId) &
                  row.startsOn.isSmallerOrEqualValue(occurredAt) &
                  (row.endsOn.isNull() |
                      row.endsOn.isBiggerThanValue(occurredAt)) &
                  row.status.isIn(const ['active', 'ended']) &
                  row.deletedAt.isNull() &
                  (cropAssignmentId == null
                      ? const Constant(true)
                      : row.id.equals(cropAssignmentId)),
            ))
            .get();
    if (correction && cropAssignmentId != null && assignments.isEmpty) {
      final effectiveAlternatives =
          await (_database.select(_database.cropSeasons)..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.sectorId.equals(sectorId) &
                    row.id.equals(cropAssignmentId).not() &
                    row.startsOn.isSmallerOrEqualValue(occurredAt) &
                    (row.endsOn.isNull() |
                        row.endsOn.isBiggerThanValue(occurredAt)) &
                    row.status.isIn(const ['active', 'ended']) &
                    row.deletedAt.isNull(),
              ))
              .get();
      if (effectiveAlternatives.isNotEmpty) {
        throw StateError('labor_correction_assignment_changed');
      }
    }
    if (assignments.length != 1) {
      throw StateError('labor_crop_context_required');
    }
    final assignment = assignments.single;
    final resolvedSeasonId = seasonId ?? assignment.agriculturalSeasonId;
    if (resolvedSeasonId == null ||
        assignment.agriculturalSeasonId != resolvedSeasonId) {
      throw StateError('labor_season_context_invalid');
    }
    final season =
        await (_database.select(_database.agriculturalSeasons)..where(
              (row) =>
                  row.id.equals(resolvedSeasonId) &
                  row.ownerId.equals(ownerId) &
                  row.parcelId.equals(parcelId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (season == null || (season.status == 'closed' && !correction)) {
      throw StateError('labor_season_closed_or_missing');
    }
    return LaborContext(
      parcelId: parcelId,
      sectorId: sectorId,
      seasonId: resolvedSeasonId,
      assignmentId: assignment.id,
      cropId: assignment.cropId,
      isCustomCrop: assignment.isCustomCrop,
    );
  }

  Future<void> _markStatus(Labor row, String status) async {
    final now = DateTime.now().toUtc();
    final version = row.version + 1;
    final details = LaborDetails.decode(row.detailsJson);
    final payload = <String, Object?>{
      'id': row.id,
      'owner_id': row.ownerId,
      'parcel_id': row.parcelId,
      'sector_id': row.sectorId,
      'agricultural_season_id': row.seasonId,
      'crop_assignment_id': row.cropAssignmentId,
      'type': row.type,
      'custom_name': row.customName,
      'details': details.toJson(),
      'details_schema_version': row.detailsSchemaVersion,
      'status': status,
      'supersedes_labor_id': row.supersedesLaborId,
      'notes': row.notes,
      'occurred_at': row.occurredAt.toIso8601String(),
      'version': version,
      'updated_at': now.toIso8601String(),
      'deleted_at': row.deletedAt?.toIso8601String(),
    };
    final dependency = await _pendingDependency(row.ownerId, 'labor', row.id);
    await (_database.update(
      _database.labors,
    )..where((labor) => labor.id.equals(row.id))).write(
      LaborsCompanion(
        status: Value(status),
        version: Value(version),
        syncState: const Value('pending'),
        updatedAt: Value(now),
      ),
    );
    await _database.syncOutboxDao.enqueue(
      _operation(
        ownerId: row.ownerId,
        aggregateId: row.id,
        mutation: 'update',
        baseVersion: row.version,
        payload: payload,
        dependency: dependency,
        createdAt: now,
      ),
    );
  }

  SyncOutboxCompanion _operation({
    required String ownerId,
    required String aggregateId,
    required String mutation,
    int? baseVersion,
    required Map<String, Object?> payload,
    String? dependency,
    required DateTime createdAt,
  }) => SyncOutboxCompanion.insert(
    operationId: EntityId.generate().value,
    ownerId: ownerId,
    aggregateType: 'labor',
    aggregateId: aggregateId,
    mutationKind: mutation,
    baseVersion: Value(baseVersion),
    payloadJson: jsonEncode(payload),
    requestHash: Value(
      syncRequestHash(
        aggregateType: 'labor',
        aggregateId: aggregateId,
        mutationKind: mutation,
        baseVersion: baseVersion,
        payload: payload,
      ),
    ),
    dependencyOperationId: Value(dependency),
    createdAt: createdAt,
  );

  Future<String?> _pendingDependency(
    String ownerId,
    String aggregateType,
    String aggregateId,
  ) async {
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
}

final class LaborContext {
  const LaborContext({
    required this.parcelId,
    required this.sectorId,
    required this.seasonId,
    required this.assignmentId,
    required this.cropId,
    required this.isCustomCrop,
  });

  final String parcelId;
  final String sectorId;
  final String seasonId;
  final String assignmentId;
  final String cropId;
  final bool isCustomCrop;
}
