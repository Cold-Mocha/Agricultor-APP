import 'package:agrocampo/features/agro_ai/data/agro_ai_gateway.dart';
import 'package:agrocampo/features/agro_ai/data/agro_ai_repository.dart';
import 'package:agrocampo/features/agro_ai/domain/agro_ai_message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/file_backed_database.dart';

final class _Gateway implements AgroAiGateway {
  _Gateway({this.fail = false});
  bool fail;
  AgroAiRequest? captured;
  @override
  Future<String> ask(AgroAiRequest request) async {
    captured = request;
    if (fail) throw StateError('offline');
    return 'Respuesta agrícola general.';
  }
}

void main() {
  test('retry after restart sends no private agricultural context', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    var database = fixture.open();
    final offlineGateway = _Gateway(fail: true);
    await expectLater(
      AgroAiRepository(database, offlineGateway).ask(
        ownerId: 'owner-1',
        question: '¿Cómo reconocer estrés hídrico?',
        clientMessageId: 'message-1',
      ),
      throwsStateError,
    );
    expect(
      offlineGateway.captured!.toJson().keys,
      unorderedEquals(['client_message_id', 'text', 'locale', 'policy']),
    );
    expect(
      offlineGateway.captured!.toJson().toString(),
      isNot(contains('sector')),
    );
    await database.close();
    database = fixture.open();
    final recoveredGateway = _Gateway();
    await AgroAiRepository(
      database,
      recoveredGateway,
    ).retry(ownerId: 'owner-1', clientMessageId: 'message-1');
    await database.close();
    database = fixture.open();
    addTearDown(database.close);
    await AgroAiRepository(
      database,
      recoveredGateway,
    ).retry(ownerId: 'owner-1', clientMessageId: 'message-1');
    final messages = await database.select(database.aiMessages).get();
    expect(messages.where((row) => row.role == 'user'), hasLength(1));
    expect(messages.where((row) => row.role == 'assistant'), hasLength(1));
    expect(messages.where((row) => row.state == 'error'), isEmpty);
  });
}
