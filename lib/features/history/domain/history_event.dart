enum HistoryEventType { labor, soil, irrigation, cropSeason, production }

final class HistoryEvent {
  const HistoryEvent({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.title,
    required this.sectorId,
    this.seasonId,
    this.detail,
  });

  final String id;
  final HistoryEventType type;
  final DateTime occurredAt;
  final String title;
  final String sectorId;
  final String? seasonId;
  final String? detail;
}

final class HistoryFilter {
  const HistoryFilter({
    required this.ownerId,
    this.parcelId,
    this.sectorId,
    this.seasonId,
  });

  final String ownerId;
  final String? parcelId;
  final String? sectorId;
  final String? seasonId;
}
