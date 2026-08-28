import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:drift/drift.dart';

final class HistoryRepository {
  HistoryRepository(this._database);

  final AppDatabase _database;

  Future<List<HistoryEvent>> list(HistoryFilter filter) async {
    final sectorIds = filter.sectorId == null
        ? (await (_database.select(_database.sectors)..where(
                    (row) =>
                        row.ownerId.equals(filter.ownerId) &
                        (filter.parcelId == null
                            ? const Constant(true)
                            : row.parcelId.equals(filter.parcelId!)),
                  ))
                  .get())
              .map((row) => row.id)
              .toSet()
        : {filter.sectorId!};
    final events = <HistoryEvent>[];
    final labors = await (_database.select(
      _database.labors,
    )..where((row) => row.ownerId.equals(filter.ownerId))).get();
    events.addAll(
      labors
          .where(
            (row) =>
                sectorIds.contains(row.sectorId) &&
                (filter.seasonId == null || row.seasonId == filter.seasonId),
          )
          .map(
            (row) => HistoryEvent(
              id: row.id,
              type: HistoryEventType.labor,
              occurredAt: row.occurredAt,
              title: row.customName ?? row.type,
              detail: row.notes,
              sectorId: row.sectorId,
              seasonId: row.seasonId,
            ),
          ),
    );
    final soil = await (_database.select(
      _database.soilMeasurements,
    )..where((row) => row.ownerId.equals(filter.ownerId))).get();
    events.addAll(
      soil
          .where((row) => sectorIds.contains(row.sectorId))
          .map(
            (row) => HistoryEvent(
              id: row.id,
              type: HistoryEventType.soil,
              occurredAt: row.measuredAt,
              title: 'Medición de suelo',
              sectorId: row.sectorId,
            ),
          ),
    );
    final irrigation = await (_database.select(
      _database.irrigationRecords,
    )..where((row) => row.ownerId.equals(filter.ownerId))).get();
    events.addAll(
      irrigation
          .where((row) => sectorIds.contains(row.sectorId))
          .map(
            (row) => HistoryEvent(
              id: row.id,
              type: HistoryEventType.irrigation,
              occurredAt: row.irrigatedAt,
              title: 'Riego ${row.irrigationType}',
              detail: row.estimatedLiters == null
                  ? null
                  : '${row.estimatedLiters!.toStringAsFixed(1)} L',
              sectorId: row.sectorId,
            ),
          ),
    );
    final production = await (_database.select(
      _database.productionRecords,
    )..where((row) => row.ownerId.equals(filter.ownerId))).get();
    events.addAll(
      production
          .where(
            (row) =>
                sectorIds.contains(row.sectorId) &&
                (filter.seasonId == null || row.seasonId == filter.seasonId),
          )
          .map(
            (row) => HistoryEvent(
              id: row.id,
              type: HistoryEventType.production,
              occurredAt: row.harvestedAt,
              title: 'Cosecha ${row.cropId}',
              detail: '${row.quantity} ${row.unit}',
              sectorId: row.sectorId,
              seasonId: row.seasonId,
            ),
          ),
    );
    events.sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
    return events;
  }
}
