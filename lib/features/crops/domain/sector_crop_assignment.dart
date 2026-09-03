import 'package:agrocampo/features/crops/domain/crop_ref.dart';

enum SectorCropAssignmentStatus { planned, active, ended, cancelled }

final class SectorCropAssignment {
  const SectorCropAssignment({
    required this.id,
    required this.ownerId,
    required this.sectorId,
    required this.agriculturalSeasonId,
    required this.crop,
    required this.status,
    required this.effectiveFrom,
    required this.version,
    required this.syncState,
    this.effectiveTo,
    this.notes,
    this.deletedAt,
  });

  final String id;
  final String ownerId;
  final String sectorId;
  final String agriculturalSeasonId;
  final CropRef crop;
  final SectorCropAssignmentStatus status;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String? notes;
  final int version;
  final String syncState;
  final DateTime? deletedAt;

  bool isEffectiveAt(DateTime instant) =>
      status == SectorCropAssignmentStatus.active &&
      !instant.isBefore(effectiveFrom) &&
      (effectiveTo == null || instant.isBefore(effectiveTo!));

  bool overlaps(DateTime start, DateTime? end) {
    final ownEnd = effectiveTo ?? DateTime.utc(9999);
    final proposedEnd = end ?? DateTime.utc(9999);
    return start.isBefore(ownEnd) && effectiveFrom.isBefore(proposedEnd);
  }

  static void validateRange(DateTime start, DateTime? end) {
    if (end != null && !end.isAfter(start)) {
      throw ArgumentError.value(end, 'effectiveTo', 'assignment_range_invalid');
    }
  }
}
