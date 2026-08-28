final class ReminderInput {
  const ReminderInput({
    required this.title,
    required this.scheduledAt,
    this.sectorId,
    this.notes,
  });

  final String title;
  final DateTime scheduledAt;
  final String? sectorId;
  final String? notes;

  void validate(DateTime now) {
    if (title.trim().isEmpty || !scheduledAt.isAfter(now)) {
      throw ArgumentError('invalid_reminder');
    }
  }
}
