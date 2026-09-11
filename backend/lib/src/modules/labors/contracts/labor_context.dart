import 'package:agrocampo_backend/src/shared/contracts/productive_domain.dart';

final class LaborContext {
  const LaborContext({
    required this.parcelId,
    required this.sectorId,
    required this.seasonId,
    required this.assignmentId,
    required this.cropId,
    required this.isCustomCrop,
    this.category = ProductiveCategory.legacyUnknown,
  });

  final String parcelId;
  final String sectorId;
  final String seasonId;
  final String assignmentId;
  final String cropId;
  final bool isCustomCrop;
  final ProductiveCategory category;
}

abstract interface class LaborContextReader {
  Future<LaborContext> resolveContext({
    required String ownerId,
    required String parcelId,
    required String sectorId,
    required DateTime occurredAt,
    String? seasonId,
    String? cropAssignmentId,
    bool correction = false,
  });
}
