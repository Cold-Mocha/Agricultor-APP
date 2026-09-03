import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/history/data/sector_history_dao.dart';
import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
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
      for (final row in labors) {
        final production = productions[row.id];
        final irrigation = irrigations[row.id];
        final laborType = LaborType.values.byName(row.type);
        events.add(
          HistoryEvent(
            id: row.id,
            groupingKey: 'labor:${row.id}',
            type: HistoryEventType.labor,
            occurredAt: row.occurredAt,
            title: row.customName ?? laborType.label,
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
          ),
        ),
      );
    }
    if (filter.type == null || filter.type == HistoryEventType.soil) {
      events.addAll(
        (await _dao.soil(filter)).map(
          (row) => HistoryEvent(
            id: row.id,
            groupingKey: 'soil:${row.id}',
            type: HistoryEventType.soil,
            occurredAt: row.measuredAt,
            title: 'Medición de suelo',
            sectorId: row.sectorId,
            detail: row.notes,
            syncState: 'local',
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
    return events.take(filter.limit).toList(growable: false);
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
}
