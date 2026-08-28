import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/export/export_snapshot.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';

final class ExportRepository {
  const ExportRepository(this._database);
  final AppDatabase _database;

  Future<AgroExportSnapshot> snapshot(String ownerId) async {
    final parcels = await (_database.select(
      _database.parcels,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    final sectors = await (_database.select(
      _database.sectors,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    final labors = await (_database.select(
      _database.labors,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    final soil = await (_database.select(
      _database.soilMeasurements,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    final irrigation = await (_database.select(
      _database.irrigationRecords,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    final production = await (_database.select(
      _database.productionRecords,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    final apiary = await (_database.select(
      _database.apiaryInspections,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    final pending = await (_database.select(
      _database.syncOutbox,
    )..where((row) => row.ownerId.equals(ownerId))).get();
    final snapshot = AgroExportSnapshot(
      generatedAt: DateTime.now().toUtc(),
      sheets: {
        'parcelas': [
          for (final row in parcels)
            {
              'id': row.id,
              'nombre': row.name,
              'localidad': row.locality,
              'pendiente': pending.any((item) => item.aggregateId == row.id),
            },
        ],
        'sectores': [
          for (final row in sectors)
            {
              'id': row.id,
              'parcela_id': row.parcelId,
              'nombre': row.name,
              'area_m2': row.areaSquareMeters,
            },
        ],
        'labores': [
          for (final row in labors)
            {
              'id': row.id,
              'sector_id': row.sectorId,
              'tipo': row.type,
              'fecha': row.occurredAt.toIso8601String(),
            },
        ],
        'suelo': [
          for (final row in soil)
            {
              'id': row.id,
              'sector_id': row.sectorId,
              'fecha': row.measuredAt.toIso8601String(),
            },
        ],
        'riego': [
          for (final row in irrigation)
            {
              'id': row.id,
              'sector_id': row.sectorId,
              'tipo': row.irrigationType,
              'fecha': row.irrigatedAt.toIso8601String(),
            },
        ],
        'produccion': [
          for (final row in production)
            {
              'id': row.id,
              'sector_id': row.sectorId,
              'cultivo': row.cropId,
              'cantidad': row.quantity,
              'unidad': row.unit,
            },
        ],
        'apicultura': [
          for (final row in apiary)
            {
              'id': row.id,
              'sector_id': row.sectorId,
              'tarea': row.taskType,
              'colmenas': row.hiveCount,
              'apicultor': row.beekeeperName,
            },
        ],
      },
    );
    await _database
        .into(_database.exportSnapshots)
        .insert(
          ExportSnapshotsCompanion.insert(
            id: EntityId.generate().value,
            ownerId: ownerId,
            status: 'complete',
            manifestJson: jsonEncode({
              'sheets': snapshot.sheets.keys.toList(),
              'generated_at': snapshot.generatedAt.toIso8601String(),
            }),
            createdAt: snapshot.generatedAt,
          ),
        );
    return snapshot;
  }
}
