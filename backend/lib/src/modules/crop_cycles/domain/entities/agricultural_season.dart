enum AgriculturalSeasonStatus { planned, active, closed }

final class AgriculturalSeason {
  const AgriculturalSeason({
    required this.id,
    required this.ownerId,
    required this.sectorId,
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
  final String sectorId;
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

  /// A season is active while today falls between its start and end, planned
  /// before it starts and closed once it ended. Dates are compared by day.
  static AgriculturalSeasonStatus statusFor({
    required DateTime startsOn,
    required DateTime endsOn,
    required DateTime today,
  }) {
    DateTime day(DateTime value) =>
        DateTime.utc(value.year, value.month, value.day);
    final now = day(today);
    if (now.isBefore(day(startsOn))) return AgriculturalSeasonStatus.planned;
    if (now.isAfter(day(endsOn))) return AgriculturalSeasonStatus.closed;
    return AgriculturalSeasonStatus.active;
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
