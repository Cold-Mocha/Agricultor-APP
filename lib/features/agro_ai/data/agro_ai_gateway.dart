import 'package:agrocampo/features/agro_ai/domain/agro_ai_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AgroAiGateway {
  Future<String> ask(AgroAiRequest request);
}

final class SupabaseAgroAiGateway implements AgroAiGateway {
  const SupabaseAgroAiGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<String> ask(AgroAiRequest request) async {
    final response = await _client.functions.invoke(
      'agro-ai',
      body: request.toJson(),
    );
    if (response.status != 200 ||
        response.data is! Map ||
        (response.data as Map)['answer'] is! String) {
      throw StateError('agro_ai_unavailable');
    }
    return (response.data as Map)['answer'] as String;
  }
}

final class UnavailableAgroAiGateway implements AgroAiGateway {
  const UnavailableAgroAiGateway();
  @override
  Future<String> ask(AgroAiRequest request) =>
      Future.error(StateError('agro_ai_not_configured'));
}
