import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/agro_ai/data/agro_ai_gateway.dart';
import 'package:agrocampo/features/agro_ai/domain/agro_ai_message.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class AgroAiRepository {
  const AgroAiRepository(this._database, this._gateway);
  final AppDatabase _database;
  final AgroAiGateway _gateway;

  Future<String> ask({
    required String ownerId,
    required String question,
    String? clientMessageId,
    String locale = 'es-CL',
  }) async {
    final trimmed = question.trim();
    if (trimmed.length < 3 || trimmed.length > 2000) {
      throw ArgumentError('invalid_question');
    }
    final clientId = clientMessageId ?? EntityId.generate().value;
    final existing =
        await (_database.select(_database.aiMessages)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.clientMessageId.equals(clientId) &
                  row.role.equals('user'),
            ))
            .getSingleOrNull();
    final now = DateTime.now().toUtc();
    if (existing == null) {
      await _database
          .into(_database.aiMessages)
          .insert(
            AiMessagesCompanion.insert(
              id: EntityId.generate().value,
              ownerId: ownerId,
              clientMessageId: Value(clientId),
              role: 'user',
              content: trimmed,
              state: const Value('sending'),
              policyVersion: const Value('agroia-general-v1'),
              createdAt: now,
            ),
          );
    } else {
      await (_database.update(
        _database.aiMessages,
      )..where((row) => row.id.equals(existing.id))).write(
        const AiMessagesCompanion(
          state: Value('sending'),
          errorCode: Value(null),
        ),
      );
    }
    try {
      final answer = await _gateway.ask(
        AgroAiRequest(clientMessageId: clientId, text: trimmed, locale: locale),
      );
      await _database.transaction(() async {
        await (_database.update(_database.aiMessages)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.clientMessageId.equals(clientId) &
                  row.role.equals('user'),
            ))
            .write(
              const AiMessagesCompanion(
                state: Value('sent'),
                errorCode: Value(null),
              ),
            );
        final reply =
            await (_database.select(_database.aiMessages)..where(
                  (row) =>
                      row.ownerId.equals(ownerId) &
                      row.replyToClientMessageId.equals(clientId) &
                      row.role.equals('assistant'),
                ))
                .getSingleOrNull();
        if (reply == null) {
          await _database
              .into(_database.aiMessages)
              .insert(
                AiMessagesCompanion.insert(
                  id: EntityId.generate().value,
                  ownerId: ownerId,
                  clientMessageId: Value(EntityId.generate().value),
                  role: 'assistant',
                  content: answer,
                  state: const Value('sent'),
                  replyToClientMessageId: Value(clientId),
                  policyVersion: const Value('agroia-general-v1'),
                  createdAt: DateTime.now().toUtc(),
                ),
              );
        }
      });
      return answer;
    } on Object {
      await (_database.update(_database.aiMessages)..where(
            (row) =>
                row.ownerId.equals(ownerId) &
                row.clientMessageId.equals(clientId) &
                row.role.equals('user'),
          ))
          .write(
            const AiMessagesCompanion(
              state: Value('error'),
              errorCode: Value('gateway_unavailable'),
            ),
          );
      rethrow;
    }
  }

  Future<String> retry({
    required String ownerId,
    required String clientMessageId,
  }) async {
    final row =
        await (_database.select(_database.aiMessages)..where(
              (value) =>
                  value.ownerId.equals(ownerId) &
                  value.clientMessageId.equals(clientMessageId) &
                  value.role.equals('user'),
            ))
            .getSingle();
    return ask(
      ownerId: ownerId,
      question: row.content,
      clientMessageId: clientMessageId,
    );
  }
}
