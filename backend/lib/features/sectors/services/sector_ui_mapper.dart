import 'dart:convert';

import 'package:agrocampo_backend/core/geometry/geo_point.dart';
import 'package:agrocampo_backend/features/history/domain/history_event.dart';
import 'package:agrocampo_backend/features/sectors/dto/sector_ui_state.dart';
import 'package:agrocampo_backend/features/sectors/repositories/sector_summary_repository.dart';

/// Converts data/domain projections into the stable state consumed by widgets.
final class SectorUiMapper {
  const SectorUiMapper._();

  static SectorCardUiState fromSummary(SectorSummary summary) =>
      SectorCardUiState(
        id: summary.id,
        parcelId: summary.parcelId,
        number: summary.number,
        kind: summary.kind,
        areaSquareMeters: summary.areaSquareMeters,
        polygon: _polygon(summary.polygonJson),
        syncState: summary.syncState,
        cropLabel: summary.cropLabel,
        statusLabel: summary.statusLabel,
        isApiary: summary.isApiary,
        cropIconAsset: summary.cropIconAsset,
        cropColorToken: summary.cropColorToken,
        seasonLabel: summary.seasonLabel,
        lastLaborType: summary.lastLaborType,
        lastLaborAt: summary.lastLaborAt,
        lastIrrigationAt: summary.lastIrrigationAt,
        lastSoilAt: summary.lastSoilAt,
        soilMoisturePercent: summary.soilMoisturePercent,
      );

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
      // Preserve the preview fallback for malformed geometry.
      return const [];
    }
  }
}
