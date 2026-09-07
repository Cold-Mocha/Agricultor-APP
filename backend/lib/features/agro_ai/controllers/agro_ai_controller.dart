import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/core/database/app_database.dart';
import 'package:agrocampo_backend/features/agro_ai/repositories/agro_ai_gateway.dart';
import 'package:agrocampo_backend/features/agro_ai/repositories/agro_ai_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final agroAiControllerProvider = Provider<AgroAiController>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final client = ref.watch(supabaseClientProvider);
  return AgroAiController._(
    database,
    AgroAiRepository(
      database,
      client == null
          ? const UnavailableAgroAiGateway()
          : SupabaseAgroAiGateway(client),
    ),
  );
});

final class AgroAiMessageView {
  const AgroAiMessageView({
    required this.clientMessageId,
    required this.role,
    required this.content,
    required this.state,
    required this.createdAt,
  });
  final String clientMessageId;
  final String role;
  final String content;
  final String state;
  final DateTime createdAt;
}

final class AgroAiController {
  AgroAiController._(this._database, this._repository);
  final AppDatabase _database;
  final AgroAiRepository _repository;

  Stream<List<AgroAiMessageView>> watchMessages(String ownerId) =>
      (_database.select(_database.aiMessages)
            ..where((row) => row.ownerId.equals(ownerId))
            ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]))
          .watch()
          .map(
            (rows) => rows
                .map(
                  (row) => AgroAiMessageView(
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
