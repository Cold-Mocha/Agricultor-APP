import 'dart:convert';

import 'package:agrocampo/src/modules/territory/presentation/state/sector_ui_state.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';

abstract final class SectorUiMapper {
  static SectorCardUiState fromSummary(SectorSummary summary) {
    final isApiary =
        summary.kind.toLowerCase() == 'apiary' ||
        summary.cropLabel.toLowerCase() == 'apicultura';
    final statusLabel =
        summary.syncState == 'conflict' || summary.syncState == 'error'
        ? 'Requiere revisar el respaldo'
        : isApiary
        ? 'Apicultura'
        : switch (summary.assignmentStatus) {
            'active' => 'Cultivo activo',
            'planned' => 'Cultivo planificado',
            _ => 'Sin cultivo asignado',
          };
    return SectorCardUiState(
      id: summary.id,
      parcelId: summary.parcelId,
      number: summary.number,
      kind: summary.kind,
      areaSquareMeters: summary.areaSquareMeters,
      polygon: _polygon(summary.polygonJson),
      syncState: summary.syncState,
      cropLabel: summary.cropLabel,
      statusLabel: statusLabel,
      isApiary: isApiary,
      cropIconAsset: summary.cropIconAsset,
      cropColorToken: summary.cropColorToken,
      seasonLabel: summary.seasonLabel,
      lastLaborType: summary.lastLaborType,
      lastLaborAt: summary.lastLaborAt,
      lastIrrigationAt: summary.lastIrrigationAt,
      lastSoilAt: summary.lastSoilAt,
      soilMoisturePercent: summary.soilMoisturePercent,
    );
  }

  static SectorHistoryPreviewUiState fromHistory(HistoryEvent event) =>
      SectorHistoryPreviewUiState(
        id: event.id,
        groupingKey: event.groupingKey,
        type: switch (event.type) {
          HistoryEventType.labor => SectorHistoryType.labor,
          HistoryEventType.soil => SectorHistoryType.soil,
          HistoryEventType.cropAssignment => SectorHistoryType.cropAssignment,
        },
        occurredAt: event.occurredAt,
        title: event.title,
        sectorId: event.sectorId,
        cropLabel: event.cropLabel,
      );

  static List<GeoPoint> _polygon(String source) {
    try {
      return List.unmodifiable(
        (jsonDecode(source) as List<Object?>).cast<Map<String, Object?>>().map(
          (value) => GeoPoint(
            (value['lat'] as num).toDouble(),
            (value['lng'] as num).toDouble(),
          ),
        ),
      );
    } on Object {
      return const [];
    }
  }
}
