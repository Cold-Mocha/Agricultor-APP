/// Stable read projection for sector cards and detail summaries.
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
}
