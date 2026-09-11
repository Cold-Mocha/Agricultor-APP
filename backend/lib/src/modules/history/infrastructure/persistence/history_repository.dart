import 'dart:convert';

import 'package:agrocampo_backend/src/modules/history/domain/entities/history_event.dart';
import 'package:agrocampo_backend/src/modules/history/infrastructure/persistence/sector_history_dao.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/shared/contracts/productive_domain.dart';
import 'package:agrocampo_backend/src/shared/contracts/save_outcome.dart';
import 'package:drift/drift.dart';

final class HistoryRepository {
  HistoryRepository(this._database) : _dao = SectorHistoryDao(_database);

  final AppDatabase _database;
  final SectorHistoryDao _dao;

  Future<List<HistoryEvent>> list(HistoryFilter filter) async {
    final events = <HistoryEvent>[];
    if (filter.type == null || filter.type == HistoryEventType.labor) {
      final labors = await _dao.labors(filter);
      final laborIds = labors.map((row) => row.id).toSet();
      final productions = await _dao.production(laborIds);
      final irrigations = await _dao.irrigation(laborIds);
      final seasons = await _seasonLabels(
        filter.ownerId,
        labors.map((row) => row.seasonId),
      );
      final cropLabels = await _cropLabels(
        filter.ownerId,
        labors.map((row) => row.cropAssignmentId),
      );
      final categories = await _sectorCategories(
        filter.ownerId,
        labors.map((row) => row.sectorId),
      );
      for (final row in labors) {
        final production = productions[row.id];
        final irrigation = irrigations[row.id];
        events.add(
          HistoryEvent(
            id: row.id,
            groupingKey: 'labor:${row.id}',
            type: HistoryEventType.labor,
            occurredAt: row.occurredAt,
            title: row.customName ?? _laborLabel(row.type),
            sectorId: row.sectorId,
            seasonId: row.seasonId,
            seasonLabel: seasons[row.seasonId],
            cropLabel: cropLabels[row.cropAssignmentId],
            detail: production != null
                ? '${production.quantity} ${production.unit}${production.qualityNotes?.isNotEmpty == true ? ' · ${production.qualityNotes}' : ''}'
                : irrigation != null
                ? '${irrigation.durationMinutes ?? ((irrigation.durationSeconds ?? 0) / 60).ceil()} min${irrigation.appliedVolumeMl == null ? '' : ' · ${(irrigation.appliedVolumeMl! / 1000).toStringAsFixed(1)} L'}'
                : row.notes,
            status: row.status,
            syncState: row.syncState,
            category:
                categories[row.sectorId] ?? ProductiveCategory.legacyUnknown,
            backupState: _backupState(row.syncState),
            details: _decodeDetails(row.detailsJson),
          ),
        );
      }
    }
    if (filter.type == null || filter.type == HistoryEventType.cropAssignment) {
      final assignments = await _dao.assignments(filter);
      final seasons = await _seasonLabels(
        filter.ownerId,
        assignments.map((row) => row.agriculturalSeasonId),
      );
      final labels = await _assignmentCropLabels(filter.ownerId, assignments);
      events.addAll(
        assignments.map(
          (row) => HistoryEvent(
            id: row.id,
            groupingKey: 'assignment:${row.id}',
            type: HistoryEventType.cropAssignment,
            occurredAt: row.startsOn,
            title: 'Cultivo asignado',
            sectorId: row.sectorId,
            seasonId: row.agriculturalSeasonId,
            seasonLabel: seasons[row.agriculturalSeasonId],
            cropLabel: labels[row.id],
            detail: row.endsOn == null
                ? 'Desde ${_date(row.startsOn)}'
                : '${_date(row.startsOn)} – ${_date(row.endsOn!)}',
            status: row.status,
            syncState: row.syncState,
            category: ProductiveCategory.crop,
            backupState: _backupState(row.syncState),
          ),
        ),
      );
    }
    if (filter.type == null || filter.type == HistoryEventType.soil) {
      final soilRows = await _dao.soil(filter);
      final linkedSoilIds = soilRows.isEmpty
          ? const <String>{}
          : (await _database
                    .customSelect(
                      'SELECT id FROM soil_measurements WHERE id IN (${List.filled(soilRows.length, '?').join(',')}) AND labor_id IS NOT NULL',
                      variables: [for (final row in soilRows) Variable(row.id)],
                    )
                    .get())
                .map((row) => row.read<String>('id'))
                .toSet();
      final soilCategories = await _sectorCategories(
        filter.ownerId,
        soilRows.map((row) => row.sectorId),
      );
      events.addAll(
        soilRows
            .where((row) => !linkedSoilIds.contains(row.id))
            .map(
              (row) => HistoryEvent(
                id: row.id,
                groupingKey: 'soil:${row.id}',
                type: HistoryEventType.soil,
                occurredAt: row.measuredAt,
                title: 'Medición de suelo',
                sectorId: row.sectorId,
                detail: row.notes,
                syncState: 'local',
                category:
                    soilCategories[row.sectorId] ??
                    ProductiveCategory.legacyUnknown,
                backupState: BackupState.pending,
              ),
            ),
      );
    }
    final filtered = filter.category == null
        ? events
        : events.where((event) => event.category == filter.category).toList();
    filtered.sort((left, right) {
      final date = right.occurredAt.compareTo(left.occurredAt);
      if (date != 0) return date;
      final type = left.type.index.compareTo(right.type.index);
      return type != 0 ? type : left.id.compareTo(right.id);
    });
    final start = filter.offset.clamp(0, filtered.length);
    final end = (start + filter.limit).clamp(start, filtered.length);
    return filtered.sublist(start, end).toList(growable: false);
  }

  Future<Map<String, ProductiveCategory>> _sectorCategories(
    String ownerId,
    Iterable<String> ids,
  ) async {
    final values = ids.toSet();
    if (values.isEmpty) return const {};
    final rows = await (_database.select(
      _database.sectors,
    )..where((row) => row.ownerId.equals(ownerId) & row.id.isIn(values))).get();
    return {
      for (final row in rows) row.id: ProductiveCategory.fromCode(row.kind),
    };
  }

  BackupState _backupState(String state) => switch (state) {
    'synced' || 'done' => BackupState.backedUp,
    'conflict' => BackupState.conflict,
    'error' => BackupState.error,
    'syncing' || 'sending' => BackupState.syncing,
    _ => BackupState.pending,
  };

  Map<String, Object?> _decodeDetails(String source) {
    try {
      final value = jsonDecode(source);
      if (value is Map<String, Object?>) {
        final data = value['data'];
        if (data is Map<String, Object?>) return data;
        return value;
      }
    } on Object {
      // Legacy malformed rows remain visible with an empty typed detail.
    }
    return const {};
  }

  Future<Map<String?, String>> _seasonLabels(
    String ownerId,
    Iterable<String?> ids,
  ) async {
    final values = ids.whereType<String>().toSet();
    if (values.isEmpty) return const {};
    final rows = await (_database.select(
      _database.agriculturalSeasons,
    )..where((row) => row.ownerId.equals(ownerId) & row.id.isIn(values))).get();
    return {for (final row in rows) row.id: row.name};
  }

  Future<Map<String?, String>> _cropLabels(
    String ownerId,
    Iterable<String?> ids,
  ) async {
    final values = ids.whereType<String>().toSet();
    if (values.isEmpty) return const {};
    final assignments = await (_database.select(
      _database.cropSeasons,
    )..where((row) => row.ownerId.equals(ownerId) & row.id.isIn(values))).get();
    return _assignmentCropLabels(ownerId, assignments);
  }

  Future<Map<String, String>> _assignmentCropLabels(
    String ownerId,
    List<CropSeason> assignments,
  ) async {
    final officialIds = assignments
        .where((row) => !row.isCustomCrop)
        .map((row) => row.cropId)
        .toSet();
    final customIds = assignments
        .where((row) => row.isCustomCrop)
        .map((row) => row.cropId)
        .toSet();
    final official = officialIds.isEmpty
        ? const <OfficialCrop>[]
        : await (_database.select(
            _database.officialCrops,
          )..where((row) => row.id.isIn(officialIds))).get();
    final custom = customIds.isEmpty
        ? const <CustomCrop>[]
        : await (_database.select(_database.customCrops)..where(
                (row) => row.ownerId.equals(ownerId) & row.id.isIn(customIds),
              ))
              .get();
    final labels = <String, String>{
      for (final row in official) row.id: row.commonName,
      for (final row in custom) row.id: row.name,
    };
    return {
      for (final row in assignments) row.id: labels[row.cropId] ?? row.cropId,
    };
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  String _laborLabel(String type) => switch (type) {
    'irrigation' => 'Riego',
    'soil' => 'Suelo',
    'fertilization' => 'Fertilización',
    'diseaseAndPestControl' => 'Control de enfermedades y plagas',
    'sowing' => 'Siembra',
    'pruning' => 'Poda',
    'harvest' => 'Cosecha',
    'apiary' => 'Apicultura',
    _ => 'Otra labor',
  };
}
