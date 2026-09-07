import 'package:agrocampo_backend/core/geometry/geo_point.dart';

enum SectorListStatus { signedOut, needsParcel, ready, error }

enum SectorDetailStatus { signedOut, notFound, ready, error }

enum SectorHistoryType { labor, soil, cropAssignment }

/// Presentation contract for a quadrant card.
///
/// It deliberately contains display-ready values instead of Drift rows or
/// repository models. Controllers own the mapping into this state; widgets
/// only render it and emit user commands.
final class SectorCardUiState {
  const SectorCardUiState({
    required this.id,
    required this.parcelId,
    required this.number,
    required this.kind,
    required this.areaSquareMeters,
    required this.polygon,
    required this.syncState,
    required this.cropLabel,
    required this.statusLabel,
    required this.isApiary,
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
  final List<GeoPoint> polygon;
  final String syncState;
  final String cropLabel;
  final String statusLabel;
  final bool isApiary;
  final String? cropIconAsset;
  final String? cropColorToken;
  final String? seasonLabel;
  final String? lastLaborType;
  final DateTime? lastLaborAt;
  final DateTime? lastIrrigationAt;
  final DateTime? lastSoilAt;
  final double? soilMoisturePercent;

  String get displayName => 'Cuadrante $number';

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

final class SectorHistoryPreviewUiState {
  const SectorHistoryPreviewUiState({
    required this.id,
    required this.groupingKey,
    required this.type,
    required this.occurredAt,
    required this.title,
    required this.sectorId,
    this.cropLabel,
  });

  final String id;
  final String groupingKey;
  final SectorHistoryType type;
  final DateTime occurredAt;
  final String title;
  final String sectorId;
  final String? cropLabel;
}

final class SectorListUiState {
  const SectorListUiState({
    required this.status,
    this.ownerId,
    this.parcelId,
    this.selectedSectorId,
    this.sectors = const [],
    this.history = const [],
    this.historyLoading = false,
    this.errorMessage,
  });

  const SectorListUiState.signedOut()
    : this(status: SectorListStatus.signedOut);

  const SectorListUiState.needsParcel({required String ownerId})
    : this(status: SectorListStatus.needsParcel, ownerId: ownerId);

  final SectorListStatus status;
  final String? ownerId;
  final String? parcelId;
  final String? selectedSectorId;
  final List<SectorCardUiState> sectors;
  final List<SectorHistoryPreviewUiState> history;
  final bool historyLoading;
  final String? errorMessage;
}

final class SectorDetailRecordUiState {
  const SectorDetailRecordUiState({
    required this.id,
    required this.parcelId,
    required this.number,
    required this.kind,
    required this.areaSquareMeters,
  });

  final String id;
  final String parcelId;
  final int number;
  final String kind;
  final double areaSquareMeters;
}

final class SectorDetailUiState {
  const SectorDetailUiState({
    required this.status,
    this.ownerId,
    this.selectedSectorId,
    this.detail,
    this.summary,
    this.errorMessage,
  });

  const SectorDetailUiState.signedOut()
    : this(status: SectorDetailStatus.signedOut);

  const SectorDetailUiState.notFound({required String ownerId})
    : this(status: SectorDetailStatus.notFound, ownerId: ownerId);

  final SectorDetailStatus status;
  final String? ownerId;
  final String? selectedSectorId;
  final SectorDetailRecordUiState? detail;
  final SectorCardUiState? summary;
  final String? errorMessage;
}
