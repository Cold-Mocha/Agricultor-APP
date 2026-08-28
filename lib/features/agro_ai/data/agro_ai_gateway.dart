import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AgroAiGateway {
  Future<String> ask(String question);
}

final class SupabaseAgroAiGateway implements AgroAiGateway {
  const SupabaseAgroAiGateway(this._client);
  final SupabaseClient _client;

  @override
  Future<String> ask(String question) async {
    final response = await _client.functions.invoke(
      'agro-ai',
      body: {'question': question},
    );
    if (response.status != 200 || response.data is! Map) {
      throw StateError('agro_ai_unavailable');
    }
    return (response.data as Map)['answer'] as String;
  }
}
