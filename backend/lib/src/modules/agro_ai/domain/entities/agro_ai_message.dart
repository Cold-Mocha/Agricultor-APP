final class AgroAiMessage {
  const AgroAiMessage({
    required this.role,
    required this.content,
    required this.createdAt,
  });
  final String role;
  final String content;
  final DateTime createdAt;
}

const agroAiDisclaimer =
    'Orientación consultiva. Verifica decisiones críticas con un profesional agrícola.';

final class AgroAiRequest {
  const AgroAiRequest({
    required this.clientMessageId,
    required this.text,
    this.locale = 'es-CL',
    this.policyVersion = 'agroia-general-v1',
  });
  final String clientMessageId;
  final String text;
  final String locale;
  final String policyVersion;

  Map<String, Object?> toJson() => {
    'client_message_id': clientMessageId,
    'text': text,
    'locale': locale,
    'policy': {'version': policyVersion},
  };
}
