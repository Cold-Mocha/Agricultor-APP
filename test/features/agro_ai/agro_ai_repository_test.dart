import 'package:agrocampo/features/agro_ai/data/agro_ai_gateway.dart';
import 'package:agrocampo/features/agro_ai/data/agro_ai_repository.dart';
import 'package:agrocampo/features/agro_ai/domain/agro_ai_message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _Gateway implements AgroAiGateway {
  AgroAiRequest? captured;
  bool fail = false;
  @override
  Future<String> ask(AgroAiRequest request) async {
    captured = request;
    if (fail) throw StateError('offline');
    return 'Respuesta consultiva para: ${request.text}';
  }
}

void main() {
  test('stores local conversation with distinct roles', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final gateway = _Gateway();
    await AgroAiRepository(
      database,
      gateway,
    ).ask(ownerId: 'owner-1', question: '¿Reviso el suelo?');
    final messages = await database.select(database.aiMessages).get();
    expect(messages.map((message) => message.role), ['user', 'assistant']);
    expect(agroAiDisclaimer, contains('consultiva'));
    expect(
      gateway.captured!.toJson().keys,
      containsAll(<String>['client_message_id', 'text', 'locale', 'policy']),
    );
    expect(gateway.captured!.toJson().toString(), isNot(contains('parcel')));
  });

  test('retry reuses client id and creates at most one response', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final gateway = _Gateway()..fail = true;
    final repository = AgroAiRepository(database, gateway);
    await expectLater(
      repository.ask(ownerId: 'owner-1', question: '¿Cómo podar?'),
      throwsStateError,
    );
    final user = await database.select(database.aiMessages).getSingle();
    expect(user.state, 'error');
    gateway.fail = false;
    await repository.retry(
      ownerId: 'owner-1',
      clientMessageId: user.clientMessageId,
    );
    await repository.retry(
      ownerId: 'owner-1',
      clientMessageId: user.clientMessageId,
    );
    final messages = await database.select(database.aiMessages).get();
    expect(messages.where((row) => row.role == 'user'), hasLength(1));
    expect(messages.where((row) => row.role == 'assistant'), hasLength(1));
  });
}
