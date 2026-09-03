import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:drift/drift.dart';

final class SectorHistoryDao {
  SectorHistoryDao(this.database);
  final AppDatabase database;

  Future<List<Labor>> labors(HistoryFilter filter) {
    final query = database.select(database.labors)
      ..where(
        (row) => row.ownerId.equals(filter.ownerId) & row.deletedAt.isNull(),
      );
    if (filter.parcelId != null) {
      query.where((row) => row.parcelId.equals(filter.parcelId!));
    }
    if (filter.sectorId != null) {
      query.where((row) => row.sectorId.equals(filter.sectorId!));
    }
    if (filter.seasonId != null) {
      query.where((row) => row.seasonId.equals(filter.seasonId!));
    }
    if (filter.from != null) {
      query.where((row) => row.occurredAt.isBiggerOrEqualValue(filter.from!));
    }
    if (filter.to != null) {
      query.where((row) => row.occurredAt.isSmallerOrEqualValue(filter.to!));
    }
    query
      ..orderBy([
        (row) => OrderingTerm.desc(row.occurredAt),
        (row) => OrderingTerm.asc(row.type),
        (row) => OrderingTerm.asc(row.id),
      ])
      ..limit(filter.limit, offset: filter.offset);
    return query.get();
  }

  Future<List<CropSeason>> assignments(HistoryFilter filter) async {
    if (filter.sectorId == null) return const [];
    final query = database.select(database.cropSeasons)
      ..where(
        (row) =>
            row.ownerId.equals(filter.ownerId) &
            row.sectorId.equals(filter.sectorId!) &
            row.deletedAt.isNull(),
      );
    if (filter.seasonId != null) {
      query.where((row) => row.agriculturalSeasonId.equals(filter.seasonId!));
    }
    query.orderBy([
      (row) => OrderingTerm.desc(row.startsOn),
      (row) => OrderingTerm.asc(row.id),
    ]);
    return query.get();
  }

  Future<List<SoilMeasurement>> soil(HistoryFilter filter) async {
    if (filter.sectorId == null) return const [];
    final query = database.select(database.soilMeasurements)
      ..where(
        (row) =>
            row.ownerId.equals(filter.ownerId) &
            row.sectorId.equals(filter.sectorId!),
      );
    if (filter.from != null) {
      query.where((row) => row.measuredAt.isBiggerOrEqualValue(filter.from!));
    }
    if (filter.to != null) {
      query.where((row) => row.measuredAt.isSmallerOrEqualValue(filter.to!));
    }
    return query.get();
  }

  Future<Map<String, ProductionRecord>> production(Set<String> laborIds) async {
    if (laborIds.isEmpty) return const {};
    final rows = await (database.select(
      database.productionRecords,
    )..where((row) => row.laborId.isIn(laborIds))).get();
    return {
      for (final row in rows)
        if (row.laborId != null) row.laborId!: row,
    };
  }

  Future<Map<String, IrrigationRecord>> irrigation(Set<String> laborIds) async {
    if (laborIds.isEmpty) return const {};
    final rows = await (database.select(
      database.irrigationRecords,
    )..where((row) => row.laborId.isIn(laborIds))).get();
    return {
      for (final row in rows)
        if (row.laborId != null) row.laborId!: row,
    };
  }
}
