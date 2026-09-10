final class AgroAiMessageSummary {
  const AgroAiMessageSummary({
    required this.clientMessageId,
    required this.role,
    required this.content,
    required this.state,
    required this.createdAt,
  });

  final String clientMessageId;
  final String role;
  final String content;
  final String state;
  final DateTime createdAt;
}
