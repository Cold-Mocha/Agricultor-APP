import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/agro_ai/contracts/dto/agro_ai_message_summary.dart';
import 'package:agrocampo_backend/src/modules/agro_ai/infrastructure/persistence/agro_ai_gateway.dart';
import 'package:agrocampo_backend/src/modules/agro_ai/infrastructure/persistence/agro_ai_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final agroAiFacadeProvider = Provider<AgroAiFacade>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final client = ref.watch(supabaseClientProvider);
  return AgroAiFacade._(
    database,
    AgroAiRepository(
      database,
      client == null
          ? const UnavailableAgroAiGateway()
          : SupabaseAgroAiGateway(client),
    ),
  );
});

final class AgroAiFacade {
  AgroAiFacade._(this._database, this._repository);
  final AppDatabase _database;
  final AgroAiRepository _repository;

  Stream<List<AgroAiMessageSummary>> watchMessages(String ownerId) =>
      (_database.select(_database.aiMessages)
            ..where((row) => row.ownerId.equals(ownerId))
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => AgroAiMessageSummary(
                    clientMessageId: row.clientMessageId,
                    role: row.role,
                    content: row.content,
                    state: row.state,
                    createdAt: row.createdAt,
                  ),
                )
                .toList(growable: false),
          );
  Future<String> ask({required String ownerId, required String question}) =>
      _repository.ask(ownerId: ownerId, question: question);
  Future<String> retry({
    required String ownerId,
    required String clientMessageId,
  }) => _repository.retry(ownerId: ownerId, clientMessageId: clientMessageId);
}
