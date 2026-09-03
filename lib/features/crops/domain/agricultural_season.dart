enum AgriculturalSeasonStatus { planned, active, closed }

final class AgriculturalSeason {
  const AgriculturalSeason({
    required this.id,
    required this.ownerId,
    required this.parcelId,
    required this.name,
    required this.startsOn,
    required this.status,
    required this.version,
    required this.syncState,
    this.endsOn,
    this.notes,
    this.isMigrationBackfill = false,
    this.deletedAt,
  });

  final String id;
  final String ownerId;
  final String parcelId;
  final String name;
  final DateTime startsOn;
  final DateTime? endsOn;
  final AgriculturalSeasonStatus status;
  final String? notes;
  final bool isMigrationBackfill;
  final int version;
  final String syncState;
  final DateTime? deletedAt;

  static void validate({
    required String name,
    required DateTime startsOn,
    required DateTime? endsOn,
    required AgriculturalSeasonStatus status,
  }) {
    if (name.trim().isEmpty || name.trim().length > 120) {
      throw ArgumentError.value(name, 'name', 'season_name_invalid');
    }
    if (endsOn != null && endsOn.isBefore(startsOn)) {
      throw ArgumentError.value(endsOn, 'endsOn', 'season_range_invalid');
    }
    if (status == AgriculturalSeasonStatus.closed && endsOn == null) {
      throw ArgumentError.value(endsOn, 'endsOn', 'closed_season_requires_end');
    }
  }

  static bool canTransition(
    AgriculturalSeasonStatus from,
    AgriculturalSeasonStatus to,
  ) => switch ((from, to)) {
    (AgriculturalSeasonStatus.planned, AgriculturalSeasonStatus.planned) ||
    (AgriculturalSeasonStatus.planned, AgriculturalSeasonStatus.active) ||
    (AgriculturalSeasonStatus.planned, AgriculturalSeasonStatus.closed) ||
    (AgriculturalSeasonStatus.active, AgriculturalSeasonStatus.active) ||
    (AgriculturalSeasonStatus.active, AgriculturalSeasonStatus.closed) ||
    (AgriculturalSeasonStatus.closed, AgriculturalSeasonStatus.closed) => true,
    _ => false,
  };
}
