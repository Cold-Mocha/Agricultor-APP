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
