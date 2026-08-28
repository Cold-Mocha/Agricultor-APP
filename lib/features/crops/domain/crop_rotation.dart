enum CropSeasonStatus { planned, active, ended, cancelled }

final class CropRotation {
  const CropRotation({
    required this.id,
    required this.sectorId,
    required this.cropId,
    required this.status,
    required this.startsOn,
    this.endsOn,
  });

  final String id;
  final String sectorId;
  final String cropId;
  final CropSeasonStatus status;
  final DateTime startsOn;
  final DateTime? endsOn;
}
