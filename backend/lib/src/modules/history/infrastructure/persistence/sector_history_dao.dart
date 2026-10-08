import 'package:agrocampo_backend/src/modules/history/domain/entities/history_event.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';

final class SectorHistoryDao {
  SectorHistoryDao(this.database);
  final AppDatabase database;

  /// Page the combined timeline before loading typed details from each source.
  Future<Map<String, List<String>>> pageIds(HistoryFilter filter) async {
    final conditions = <String>['e.owner_id = ?'];
    final variables = <Variable>[Variable(filter.ownerId)];
    void where(String condition, Variable value) {
      conditions.add(condition);
      variables.add(value);
    }

    if (filter.sectorId != null) {
      where('e.sector_id = ?', Variable(filter.sectorId!));
    }
    if (filter.seasonId != null) {
      where('e.season_id = ?', Variable(filter.seasonId!));
    }
    if (filter.type != null) where('e.type = ?', Variable(filter.type!.index));
    if (filter.from != null) {
      where('e.occurred_at >= ?', Variable(filter.from!));
    }
    if (filter.to != null) where('e.occurred_at <= ?', Variable(filter.to!));
    if (filter.category != null) {
      where(
        "CASE WHEN e.source = 'assignment' THEN 'crop' "
        "WHEN s.kind IN ('crop', 'apiary') THEN s.kind ELSE 'legacyUnknown' END = ?",
        Variable(filter.category!.code),
      );
    }
    variables.addAll([Variable(filter.limit), Variable(filter.offset)]);
    final rows = await database.customSelect('''
      WITH events AS (
        SELECT 'labor' AS source, id, owner_id, sector_id, season_id,
          occurred_at, CASE WHEN type = 'soil' THEN 1 ELSE 0 END AS type
        FROM labors WHERE deleted_at IS NULL
        UNION ALL
        SELECT 'assignment', id, owner_id, sector_id, agricultural_season_id,
          starts_on, 2 FROM crop_seasons WHERE deleted_at IS NULL
        UNION ALL
        SELECT 'soil', id, owner_id, sector_id, NULL, measured_at, 1
        FROM soil_measurements WHERE labor_id IS NULL
      )
      SELECT e.source, e.id FROM events e
      LEFT JOIN sectors s ON s.id = e.sector_id AND s.owner_id = e.owner_id
      WHERE ${conditions.join(' AND ')}
      ORDER BY e.occurred_at DESC, e.type ASC, e.id ASC
      LIMIT ? OFFSET ?
    ''', variables: variables).get();
    final result = <String, List<String>>{};
    for (final row in rows) {
      (result[row.read<String>('source')] ??= []).add(row.read<String>('id'));
    }
    return result;
  }

  Future<List<Labor>> labors(String ownerId, {List<String>? ids}) {
    final query = database.select(database.labors)
      ..where((row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull());
    if (ids != null) query.where((row) => row.id.isIn(ids));
    return query.get();
  }

  Future<List<CropSeason>> assignments(
    String ownerId, {
    List<String>? ids,
  }) async {
    final query = database.select(database.cropSeasons)
      ..where((row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull());
    if (ids != null) query.where((row) => row.id.isIn(ids));
    return query.get();
  }

  Future<List<SoilMeasurement>> soil(
    String ownerId, {
    List<String>? ids,
  }) async {
    // Linked readings are represented once, through their labor event.
    final query = database.select(database.soilMeasurements)
      ..where((row) => row.ownerId.equals(ownerId) & row.laborId.isNull());
    if (ids != null) query.where((row) => row.id.isIn(ids));
    return query.get();
  }

  Future<Map<String, ProductionRecord>> production(
    Set<String> laborIds,
    String ownerId,
  ) async {
    if (laborIds.isEmpty) return const {};
    final rows =
        await (database.select(database.productionRecords)..where(
              (row) => row.ownerId.equals(ownerId) & row.laborId.isIn(laborIds),
            ))
            .get();
    return {
      for (final row in rows)
        if (row.laborId != null) row.laborId!: row,
    };
  }

  Future<Map<String, IrrigationRecord>> irrigation(
    Set<String> laborIds,
    String ownerId,
  ) async {
    if (laborIds.isEmpty) return const {};
    final rows =
        await (database.select(database.irrigationRecords)..where(
              (row) => row.ownerId.equals(ownerId) & row.laborId.isIn(laborIds),
            ))
            .get();
    return {
      for (final row in rows)
        if (row.laborId != null) row.laborId!: row,
    };
  }

  Future<Map<String, SoilMeasurement>> linkedSoil(
    Set<String> ids,
    String ownerId,
  ) async {
    if (ids.isEmpty) return const {};
    final rows =
        await (database.select(database.soilMeasurements)..where(
              (row) => row.ownerId.equals(ownerId) & row.laborId.isIn(ids),
            ))
            .get();
    return {
      for (final row in rows)
        if (row.laborId != null) row.laborId!: row,
    };
  }

  Future<Map<String, ApiaryInspection>> apiary(
    Set<String> ids,
    String ownerId,
  ) async {
    if (ids.isEmpty) return const {};
    final rows =
        await (database.select(database.apiaryInspections)..where(
              (row) => row.ownerId.equals(ownerId) & row.laborId.isIn(ids),
            ))
            .get();
    return {
      for (final row in rows)
        if (row.laborId != null) row.laborId!: row,
    };
  }
}
