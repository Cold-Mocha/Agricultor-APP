import 'dart:convert';

import 'package:agrocampo_backend/src/modules/export/infrastructure/export_snapshot.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/shared/kernel/entity_id.dart';
import 'package:drift/drift.dart';

final class ExportRepository {
  const ExportRepository(this._database);
  final AppDatabase _database;

  Future<AgroExportSnapshot> snapshot(String ownerId) async {
    // Only sectors the owner hasn't deleted are exported; every detail sheet
    // below is scoped to this set so a deleted sector's labors, soil
    // readings, irrigation, production and apiary records disappear with it,
    // matching what the rest of the app (e.g. the history screen) shows.
    final sectors =
        await (_database.select(_database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull(),
            ))
            .get();
    final sectorIds = sectors.map((row) => row.id).toSet();

    final labors = sectorIds.isEmpty
        ? const <Labor>[]
        : await (_database.select(_database.labors)..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.deletedAt.isNull() &
                    row.sectorId.isIn(sectorIds),
              ))
              .get();
    final soil = sectorIds.isEmpty
        ? const <SoilMeasurement>[]
        : await (_database.select(_database.soilMeasurements)..where(
                (row) =>
                    row.ownerId.equals(ownerId) & row.sectorId.isIn(sectorIds),
              ))
              .get();
    final irrigation = sectorIds.isEmpty
        ? const <IrrigationRecord>[]
        : await (_database.select(_database.irrigationRecords)..where(
                (row) =>
                    row.ownerId.equals(ownerId) & row.sectorId.isIn(sectorIds),
              ))
              .get();
    final production = sectorIds.isEmpty
        ? const <ProductionRecord>[]
        : await (_database.select(_database.productionRecords)..where(
                (row) =>
                    row.ownerId.equals(ownerId) & row.sectorId.isIn(sectorIds),
              ))
              .get();
    final apiary = sectorIds.isEmpty
        ? const <ApiaryInspection>[]
        : await (_database.select(_database.apiaryInspections)..where(
                (row) =>
                    row.ownerId.equals(ownerId) & row.sectorId.isIn(sectorIds),
              ))
              .get();
    final snapshot = AgroExportSnapshot(
      generatedAt: DateTime.now().toUtc(),
      sheets: {
        'sectores': [
          for (final row in sectors)
            {
              'id': row.id,
              'numero': row.number,
              'nombre': row.name,
              'tipo': row.kind,
              'area_m2': row.areaSquareMeters,
              'estado_sync': row.syncState,
              'actualizado': row.updatedAt.toIso8601String(),
            },
        ],
        'labores': [
          for (final row in labors)
            {
              'id': row.id,
              'sector_id': row.sectorId,
              'temporada_id': row.seasonId,
              'asignacion_id': row.cropAssignmentId,
              'tipo': row.type,
              'categoria_dominio': row.domainCategory,
              'nombre_personalizado': row.customName,
              'estado': row.status,
              'labor_reemplazada_id': row.supersedesLaborId,
              'notas': row.notes,
              'detalle_json': row.detailsJson,
              'fecha': row.occurredAt.toIso8601String(),
              'estado_sync': row.syncState,
              'actualizado': row.updatedAt.toIso8601String(),
            },
        ],
        'suelo': [
          for (final row in soil)
            {
              'id': row.id,
              'sector_id': row.sectorId,
              'labor_id': row.laborId,
              'humedad_pct': row.moisturePercent,
              'ph': row.ph,
              'temperatura_c': row.temperatureCelsius,
              'conductividad': row.conductivity,
              'nitrogeno': row.nitrogen,
              'fosforo': row.phosphorus,
              'potasio': row.potassium,
              'notas': row.notes,
              'fecha': row.measuredAt.toIso8601String(),
              'actualizado': row.updatedAt.toIso8601String(),
            },
        ],
        'riego': [
          for (final row in irrigation)
            {
              'id': row.id,
              'sector_id': row.sectorId,
              'labor_id': row.laborId,
              'tipo': row.irrigationType,
              'tipo_suelo': row.soilTypeCode,
              'caudal_l_h': row.flowLitersPerHour,
              'duracion_min': row.durationMinutes,
              'duracion_seg': row.durationSeconds,
              'litros_estimados': row.estimatedLiters,
              'volumen_aplicado_ml': row.appliedVolumeMl,
              'config_id': row.configId,
              'config_version': row.configVersion,
              'fecha': row.irrigatedAt.toIso8601String(),
              'actualizado': row.updatedAt.toIso8601String(),
            },
        ],
        'produccion': [
          for (final row in production)
            {
              'id': row.id,
              'sector_id': row.sectorId,
              'labor_id': row.laborId,
              'temporada_id': row.seasonId,
              'cultivo': row.cropId,
              'cantidad': row.quantity,
              'unidad': row.unit,
              'notas_calidad': row.qualityNotes,
              'fecha': row.harvestedAt.toIso8601String(),
              'actualizado': row.updatedAt.toIso8601String(),
            },
        ],
        'apicultura': [
          for (final row in apiary)
            {
              'id': row.id,
              'sector_id': row.sectorId,
              'labor_id': row.laborId,
              'tarea': row.taskType,
              'apicultor': row.beekeeperName,
              'colmenas': row.hiveCount,
              'estado_reina': row.queenStatus,
              'estado_cria': row.broodStatus,
              'estado_alimentacion': row.feedingStatus,
              'notas_salud': row.healthNotes,
              'notas_plagas': row.pestNotes,
              'alza_instalada': row.superInstalled,
              'observaciones': row.observations,
              'fecha': row.inspectedAt.toIso8601String(),
              'actualizado': row.updatedAt.toIso8601String(),
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
