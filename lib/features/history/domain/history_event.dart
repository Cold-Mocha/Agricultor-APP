enum HistoryEventType { labor, soil, cropAssignment }

final class HistoryEvent {
  const HistoryEvent({
    required this.id,
    required this.groupingKey,
    required this.type,
    required this.occurredAt,
    required this.title,
    required this.sectorId,
    required this.syncState,
    this.seasonId,
    this.seasonLabel,
    this.cropLabel,
    this.detail,
    this.status,
  });

  final String id;
  final String groupingKey;
  final HistoryEventType type;
  final DateTime occurredAt;
  final String title;
  final String sectorId;
  final String? seasonId;
  final String? seasonLabel;
  final String? cropLabel;
  final String? detail;
  final String? status;
  final String syncState;
}

final class HistoryFilter {
  const HistoryFilter({
    required this.ownerId,
    this.parcelId,
    this.sectorId,
    this.seasonId,
    this.type,
    this.from,
    this.to,
    this.limit = 100,
    this.offset = 0,
  });

  final String ownerId;
  final String? parcelId;
  final String? sectorId;
  final String? seasonId;
  final HistoryEventType? type;
  final DateTime? from;
  final DateTime? to;
  final int limit;
  final int offset;
}
