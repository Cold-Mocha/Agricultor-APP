final class ReminderInput {
  const ReminderInput({
    required this.title,
    required this.scheduledAt,
    this.sectorId,
    this.parcelId,
    this.description,
    this.notes,
    this.sourceTimeZone = 'UTC',
  });

  final String title;
  final DateTime scheduledAt;
  final String? sectorId;
  final String? parcelId;
  final String? description;
  final String? notes;
  final String sourceTimeZone;

  void validate(DateTime now) {
    if (title.trim().isEmpty ||
        title.trim().length > 120 ||
        !scheduledAt.isAfter(now) ||
        (description?.length ?? 0) > 500) {
      throw ArgumentError('invalid_reminder');
    }
  }
}
