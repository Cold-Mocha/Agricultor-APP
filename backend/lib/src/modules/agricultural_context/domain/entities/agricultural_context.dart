final class AgriculturalContext {
  const AgriculturalContext({
    this.ownerId,
    this.parcelId,
    this.sectorId,
    this.seasonId,
    this.assignmentId,
    this.revision = 0,
    this.isRestoring = false,
  });

  const AgriculturalContext.restoring(String ownerId)
    : this(ownerId: ownerId, isRestoring: true);

  final String? ownerId;
  final String? parcelId;
  final String? sectorId;
  final String? seasonId;
  final String? assignmentId;
  final int revision;
  final bool isRestoring;

  AgriculturalContext copyWith({
    String? parcelId,
    bool clearParcel = false,
    String? sectorId,
    bool clearSector = false,
    String? seasonId,
    bool clearSeason = false,
    String? assignmentId,
    bool clearAssignment = false,
    int? revision,
    bool? isRestoring,
  }) => AgriculturalContext(
    ownerId: ownerId,
    parcelId: clearParcel ? null : parcelId ?? this.parcelId,
    sectorId: clearSector ? null : sectorId ?? this.sectorId,
    seasonId: clearSeason ? null : seasonId ?? this.seasonId,
    assignmentId: clearAssignment ? null : assignmentId ?? this.assignmentId,
    revision: revision ?? this.revision,
    isRestoring: isRestoring ?? this.isRestoring,
  );
}

final class BoundAgriculturalContext {
  const BoundAgriculturalContext({
    required this.ownerId,
    required this.parcelId,
    required this.sectorId,
    required this.seasonId,
    required this.assignmentId,
    required this.revision,
  });

  factory BoundAgriculturalContext.from(
    AgriculturalContext context, {
    String? parcelId,
    String? sectorId,
    String? seasonId,
    String? assignmentId,
  }) => BoundAgriculturalContext(
    ownerId: context.ownerId,
    parcelId: parcelId ?? context.parcelId,
    sectorId: sectorId ?? context.sectorId,
    seasonId: seasonId ?? context.seasonId,
    assignmentId: assignmentId ?? context.assignmentId,
    revision: context.revision,
  );

  final String? ownerId;
  final String? parcelId;
  final String? sectorId;
  final String? seasonId;
  final String? assignmentId;
  final int revision;

  bool differsFrom(AgriculturalContext current) =>
      ownerId != current.ownerId ||
      parcelId != current.parcelId ||
      sectorId != current.sectorId ||
      seasonId != current.seasonId ||
      assignmentId != current.assignmentId;
}
