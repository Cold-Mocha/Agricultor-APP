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

  Stream<List<HistoryEvent>> watch(HistoryFilter filter) => _database
      .customSelect(
        'SELECT 1 AS history_events',
        readsFrom: {
          _database.labors,
          _database.soilMeasurements,
          _database.cropSeasons,
          _database.sectors,
          _database.agriculturalSeasons,
          _database.officialCrops,
          _database.customCrops,
          _database.productionRecords,
          _database.irrigationRecords,
          _database.apiaryInspections,
        },
      )
      .watch()
      .asyncMap((_) => list(filter));

  Stream<List<HistorySector>> watchSectors(String ownerId) => _database
      .customSelect(
        'SELECT 1 AS history_sectors',
        readsFrom: {_database.sectors, _database.agriculturalSeasons},
      )
      .watch()
      .asyncMap((_) async {
        final sectors =
            await (_database.select(_database.sectors)
                  ..where((row) => row.ownerId.equals(ownerId))
                  ..orderBy([(row) => OrderingTerm.asc(row.number)]))
                .get();
        final seasons =
            await (_database.select(_database.agriculturalSeasons)
                  ..where((row) => row.ownerId.equals(ownerId))
                  ..orderBy([(row) => OrderingTerm.desc(row.startsOn)]))
                .get();
        return [
          for (final row in sectors)
            HistorySector(
              id: row.id,
              number: row.number,
              name: row.name,
              retired: row.deletedAt != null,
              seasons: [
                for (final season in seasons.where((s) => s.sectorId == row.id))
                  HistorySeason(id: season.id, name: season.name),
              ],
            ),
        ];
      });

  Future<List<HistoryEvent>> list(HistoryFilter filter) async {
    if (filter.limit <= 0 || filter.offset < 0) {
      throw ArgumentError('history_pagination_invalid');
    }
    if (filter.from != null &&
        filter.to != null &&
        filter.from!.isAfter(filter.to!)) {
      throw ArgumentError('history_date_range_invalid');
    }
    return _project(filter, paginated: true);
  }

  Future<List<HistoryEvent>> listAll(String ownerId) =>
      _project(HistoryFilter(ownerId: ownerId));

  Future<List<HistoryEvent>> _project(
    HistoryFilter filter, {
    bool paginated = false,
  }) async {
    final page = paginated ? await _dao.pageIds(filter) : null;
    if (page != null && page.isEmpty) return const [];
    final sectors = await (_database.select(
      _database.sectors,
    )..where((row) => row.ownerId.equals(filter.ownerId))).get();
    final sectorById = {for (final row in sectors) row.id: row};
    final categories = {
      for (final row in sectors) row.id: ProductiveCategory.fromCode(row.kind),
    };
    final events = <HistoryEvent>[];
    if (filter.type == null ||
        filter.type == HistoryEventType.labor ||
        filter.type == HistoryEventType.soil) {
      final labors = await _dao.labors(
        filter.ownerId,
        ids: page == null ? null : page['labor'] ?? const [],
      );
      final laborIds = labors.map((row) => row.id).toSet();
      final productions = await _dao.production(laborIds, filter.ownerId);
      final irrigations = await _dao.irrigation(laborIds, filter.ownerId);
      final soil = await _dao.linkedSoil(laborIds, filter.ownerId);
      final apiary = await _dao.apiary(laborIds, filter.ownerId);
      final replacements =
          await (_database.select(_database.labors)..where(
                (row) =>
                    row.ownerId.equals(filter.ownerId) &
                    row.deletedAt.isNull() &
                    row.supersedesLaborId.isIn(laborIds),
              ))
              .get();
      final replacedBy = {
        for (final row in replacements) row.supersedesLaborId: row.id,
      };
      final seasons = await _seasonLabels(
        filter.ownerId,
        labors.map((row) => row.seasonId),
      );
      final cropLabels = await _cropLabels(
        filter.ownerId,
        labors.map((row) => row.cropAssignmentId),
      );
      for (final row in labors) {
        final production = productions[row.id];
        final irrigation = irrigations[row.id];
        final reading = soil[row.id];
        final inspection = apiary[row.id];
        events.add(
          HistoryEvent(
            id: row.id,
            groupingKey: 'labor:${row.id}',
            type: row.type == 'soil'
                ? HistoryEventType.soil
                : HistoryEventType.labor,
            occurredAt: row.occurredAt,
            title: row.customName ?? _laborLabel(row.type),
            sectorId: row.sectorId,
            sectorNumber: sectorById[row.sectorId]?.number,
            sectorName: sectorById[row.sectorId]?.name,
            sectorRetired: sectorById[row.sectorId]?.deletedAt != null,
            supersedesLaborId: row.supersedesLaborId,
            replacedByLaborId: replacedBy[row.id],
            seasonId: row.seasonId,
            seasonLabel: seasons[row.seasonId],
            cropLabel: cropLabels[row.cropAssignmentId],
            detail: production != null
                ? '${production.quantity} ${production.unit}${production.qualityNotes?.isNotEmpty == true ? ' · ${production.qualityNotes}' : ''}'
                : irrigation != null
                ? '${irrigation.durationMinutes ?? ((irrigation.durationSeconds ?? 0) / 60).ceil()} min${irrigation.appliedVolumeMl == null ? '' : ' · ${(irrigation.appliedVolumeMl! / 1000).toStringAsFixed(1)} L'}'
                : row.notes ?? reading?.notes ?? inspection?.observations,
            status: row.status,
            syncState: row.syncState,
            category:
                categories[row.sectorId] ?? ProductiveCategory.legacyUnknown,
            backupState: _backupState(row.syncState),
            details: {
              ..._decodeDetails(row.detailsJson),
              if (row.notes != null) 'notes': row.notes,
              if (production != null) ...{
                'quantity': production.quantity,
                'unit': production.unit,
                'qualityNotes': production.qualityNotes,
              },
              if (irrigation != null) ...{
                'irrigationType': irrigation.irrigationType,
                'soilTypeCode': irrigation.soilTypeCode,
                'flowLitersPerHour': irrigation.flowLitersPerHour,
                'durationMinutes': irrigation.durationMinutes,
                'durationSeconds': irrigation.durationSeconds,
                'estimatedLiters': irrigation.estimatedLiters,
                'appliedVolumeMl': irrigation.appliedVolumeMl,
                'configId': irrigation.configId,
                'configVersion': irrigation.configVersion,
              },
              if (reading != null) ...{
                'moisturePercent': reading.moisturePercent,
                'ph': reading.ph,
                'temperatureCelsius': reading.temperatureCelsius,
                'conductivity': reading.conductivity,
                'nitrogen': reading.nitrogen,
                'phosphorus': reading.phosphorus,
                'potassium': reading.potassium,
              },
              if (inspection != null) ...{
                'taskType': inspection.taskType,
                'beekeeperName': inspection.beekeeperName,
                'hiveCount': inspection.hiveCount,
                'queenStatus': inspection.queenStatus,
                'broodStatus': inspection.broodStatus,
                'feedingStatus': inspection.feedingStatus,
                'healthNotes': inspection.healthNotes,
                'pestNotes': inspection.pestNotes,
                'superInstalled': inspection.superInstalled,
                'observations': inspection.observations,
              },
            },
            laborType: row.type,
          ),
        );
      }
    }
    if (filter.type == null || filter.type == HistoryEventType.cropAssignment) {
      final assignments = await _dao.assignments(
        filter.ownerId,
        ids: page == null ? null : page['assignment'] ?? const [],
      );
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
            sectorNumber: sectorById[row.sectorId]?.number,
            sectorName: sectorById[row.sectorId]?.name,
            sectorRetired: sectorById[row.sectorId]?.deletedAt != null,
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
            details: {
              'startsOn': row.startsOn.toIso8601String(),
              'endsOn': row.endsOn?.toIso8601String(),
              'cropId': row.cropId,
            },
          ),
        ),
      );
    }
    if (filter.type == null || filter.type == HistoryEventType.soil) {
      final soilRows = await _dao.soil(
        filter.ownerId,
        ids: page == null ? null : page['soil'] ?? const [],
      );
      events.addAll(
        soilRows.map(
          (row) => HistoryEvent(
            id: row.id,
            groupingKey: 'soil:${row.id}',
            type: HistoryEventType.soil,
            occurredAt: row.measuredAt,
            title: 'Medición de suelo',
            sectorId: row.sectorId,
            sectorNumber: sectorById[row.sectorId]?.number,
            sectorName: sectorById[row.sectorId]?.name,
            sectorRetired: sectorById[row.sectorId]?.deletedAt != null,
            detail: row.notes,
            status: 'recorded',
            details: {
              'moisturePercent': row.moisturePercent,
              'ph': row.ph,
              'temperatureCelsius': row.temperatureCelsius,
              'conductivity': row.conductivity,
              'nitrogen': row.nitrogen,
              'phosphorus': row.phosphorus,
              'potassium': row.potassium,
            },
            syncState: 'local',
            category:
                categories[row.sectorId] ?? ProductiveCategory.legacyUnknown,
            backupState: BackupState.pending,
          ),
        ),
      );
    }
    events.sort((left, right) {
      final date = right.occurredAt.compareTo(left.occurredAt);
      if (date != 0) return date;
      final type = left.type.index.compareTo(right.type.index);
      return type != 0 ? type : left.id.compareTo(right.id);
    });
    return events;
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
