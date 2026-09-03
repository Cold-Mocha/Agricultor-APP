import 'package:agrocampo/core/database/app_database.dart';
import 'package:drift/drift.dart';

/// Read model for the quadrant cards. The persisted aggregate remains Sector;
/// this projection only gathers data already stored by existing features.
final class SectorSummary {
  const SectorSummary({
    required this.id,
    required this.parcelId,
    required this.number,
    required this.kind,
    required this.areaSquareMeters,
    required this.polygonJson,
    required this.syncState,
    required this.cropLabel,
    required this.assignmentStatus,
    this.cropIconAsset,
    this.cropColorToken,
    this.seasonLabel,
    this.lastLaborType,
    this.lastLaborAt,
    this.lastIrrigationAt,
    this.lastSoilAt,
    this.soilMoisturePercent,
  });

  final String id;
  final String parcelId;
  final int number;
  final String kind;
  final double areaSquareMeters;
  final String polygonJson;
  final String syncState;
  final String cropLabel;
  final String? cropIconAsset;
  final String? cropColorToken;
  final String? assignmentStatus;
  final String? seasonLabel;
  final String? lastLaborType;
  final DateTime? lastLaborAt;
  final DateTime? lastIrrigationAt;
  final DateTime? lastSoilAt;
  final double? soilMoisturePercent;

  String get displayName => 'Cuadrante $number';

  bool get isApiary =>
      kind.toLowerCase() == 'apiary' || cropLabel.toLowerCase() == 'apicultura';

  String get statusLabel {
    if (syncState == 'conflict' || syncState == 'error') {
      return 'Requiere revisar el respaldo';
    }
    if (isApiary) return 'Apicultura';
    return switch (assignmentStatus) {
      'active' => 'Cultivo activo',
      'planned' => 'Cultivo planificado',
      _ => 'Sin cultivo asignado',
    };
  }

  DateTime? get lastRecordAt {
    final dates = [
      lastLaborAt,
      lastIrrigationAt,
      lastSoilAt,
    ].whereType<DateTime>().toList();
    if (dates.isEmpty) return null;
    dates.sort((left, right) => right.compareTo(left));
    return dates.first;
  }
}

final class SectorSummaryRepository {
  const SectorSummaryRepository(this._database);

  final AppDatabase _database;

  Stream<List<SectorSummary>> watch({
    required String ownerId,
    required String parcelId,
  }) => _database
      .customSelect(
        '''
        SELECT
          s.id,
          s.parcel_id,
          s.number,
          s.kind,
          s.area_square_meters,
          s.polygon_json,
          s.sync_state,
          ca.status AS assignment_status,
          COALESCE(oc.common_name, cc.name, 'Sin cultivo') AS crop_label,
          COALESCE(
            oc.icon_asset,
            CASE WHEN ca.is_custom_crop = 1
              THEN 'assets/icons/crops/custom-crop.svg'
            END
          ) AS crop_icon_asset,
          COALESCE(
            oc.color_token,
            CASE WHEN ca.is_custom_crop = 1 THEN 'cropCustom' END
          ) AS crop_color_token,
          ag.name AS season_label,
          (
            SELECT l.type
            FROM labors l
            WHERE l.sector_id = s.id AND l.deleted_at IS NULL
            ORDER BY l.occurred_at DESC
            LIMIT 1
          ) AS last_labor_type,
          (
            SELECT l.occurred_at
            FROM labors l
            WHERE l.sector_id = s.id AND l.deleted_at IS NULL
            ORDER BY l.occurred_at DESC
            LIMIT 1
          ) AS last_labor_at,
          (
            SELECT i.irrigated_at
            FROM irrigation_records i
            WHERE i.sector_id = s.id
            ORDER BY i.irrigated_at DESC
            LIMIT 1
          ) AS last_irrigation_at,
          (
            SELECT sm.measured_at
            FROM soil_measurements sm
            WHERE sm.sector_id = s.id
            ORDER BY sm.measured_at DESC
            LIMIT 1
          ) AS last_soil_at,
          (
            SELECT sm.moisture_percent
            FROM soil_measurements sm
            WHERE sm.sector_id = s.id
            ORDER BY sm.measured_at DESC
            LIMIT 1
          ) AS soil_moisture_percent
        FROM sectors s
        LEFT JOIN crop_seasons ca ON ca.id = (
          SELECT cs.id
          FROM crop_seasons cs
          WHERE cs.sector_id = s.id
            AND cs.deleted_at IS NULL
            AND cs.status IN ('active', 'planned')
          ORDER BY CASE cs.status WHEN 'active' THEN 0 ELSE 1 END,
                   cs.starts_on DESC
          LIMIT 1
        )
        LEFT JOIN official_crops oc
          ON ca.is_custom_crop = 0 AND oc.id = ca.crop_id
        LEFT JOIN custom_crops cc
          ON ca.is_custom_crop = 1 AND cc.id = ca.crop_id
        LEFT JOIN agricultural_seasons ag
          ON ag.id = ca.agricultural_season_id
        WHERE s.owner_id = ?
          AND s.parcel_id = ?
          AND s.deleted_at IS NULL
        ORDER BY s.number ASC
        ''',
        variables: [Variable(ownerId), Variable(parcelId)],
        readsFrom: {
          _database.sectors,
          _database.cropSeasons,
          _database.officialCrops,
          _database.customCrops,
          _database.agriculturalSeasons,
          _database.labors,
          _database.irrigationRecords,
          _database.soilMeasurements,
        },
      )
      .watch()
      .map(
        (rows) => rows
            .map(
              (row) => SectorSummary(
                id: row.read<String>('id'),
                parcelId: row.read<String>('parcel_id'),
                number: row.read<int>('number'),
                kind: row.read<String>('kind'),
                areaSquareMeters: row.read<double>('area_square_meters'),
                polygonJson: row.read<String>('polygon_json'),
                syncState: row.read<String>('sync_state'),
                cropLabel: row.read<String>('crop_label'),
                cropIconAsset: row.readNullable<String>('crop_icon_asset'),
                cropColorToken: row.readNullable<String>('crop_color_token'),
                assignmentStatus: row.readNullable<String>('assignment_status'),
                seasonLabel: row.readNullable<String>('season_label'),
                lastLaborType: row.readNullable<String>('last_labor_type'),
                lastLaborAt: _date(row, 'last_labor_at'),
                lastIrrigationAt: _date(row, 'last_irrigation_at'),
                lastSoilAt: _date(row, 'last_soil_at'),
                soilMoisturePercent: row.readNullable<double>(
                  'soil_moisture_percent',
                ),
              ),
            )
            .toList(growable: false),
      );

  static DateTime? _date(QueryRow row, String key) {
    final value = row.readNullable<String>(key);
    return value == null ? null : DateTime.tryParse(value);
  }
}
