final class ReminderSummary {
  const ReminderSummary({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.status,
    required this.notificationState,
    required this.syncState,
    this.description,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime scheduledAt;
  final String status;
  final String notificationState;
  final String syncState;
}
