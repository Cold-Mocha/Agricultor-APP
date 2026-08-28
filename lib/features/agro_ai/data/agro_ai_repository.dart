import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/agro_ai/data/agro_ai_gateway.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';

final class AgroAiRepository {
  const AgroAiRepository(this._database, this._gateway);
  final AppDatabase _database;
  final AgroAiGateway _gateway;

  Future<String> ask({
    required String ownerId,
    required String question,
  }) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) throw ArgumentError('empty_question');
    final now = DateTime.now().toUtc();
    await _database
        .into(_database.aiMessages)
        .insert(
          AiMessagesCompanion.insert(
            id: EntityId.generate().value,
            ownerId: ownerId,
            role: 'user',
            content: trimmed,
            createdAt: now,
          ),
        );
    final answer = await _gateway.ask(trimmed);
    await _database
        .into(_database.aiMessages)
        .insert(
          AiMessagesCompanion.insert(
            id: EntityId.generate().value,
            ownerId: ownerId,
            role: 'assistant',
            content: answer,
            createdAt: DateTime.now().toUtc(),
          ),
        );
    return answer;
  }
}
