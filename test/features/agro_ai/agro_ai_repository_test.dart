import 'package:agrocampo/features/agro_ai/data/agro_ai_gateway.dart';
import 'package:agrocampo/features/agro_ai/data/agro_ai_repository.dart';
import 'package:agrocampo/features/agro_ai/domain/agro_ai_message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _Gateway implements AgroAiGateway {
  @override
  Future<String> ask(String question) async =>
      'Respuesta consultiva para: $question';
}

void main() {
  test('stores local conversation with distinct roles', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await AgroAiRepository(
      database,
      _Gateway(),
    ).ask(ownerId: 'owner-1', question: '¿Reviso el suelo?');
    final messages = await database.select(database.aiMessages).get();
    expect(messages.map((message) => message.role), ['user', 'assistant']);
    expect(agroAiDisclaimer, contains('consultiva'));
  });
}
