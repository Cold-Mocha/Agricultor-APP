import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';

enum ConflictChoice { keepLocal, keepRemote }

final class ConflictResolver {
  ConflictResolver(this._database);

  final AppDatabase _database;

  Future<void> resolve(String conflictId, ConflictChoice choice) async {
    final conflict = await (_database.select(
      _database.syncConflicts,
    )..where((row) => row.conflictId.equals(conflictId))).getSingle();
    final operationId = '$conflictId-${choice.name}-resolution';
    await _database.transaction(() async {
      if (choice == ConflictChoice.keepLocal) {
        await _database.syncOutboxDao.enqueue(
          SyncOutboxCompanion.insert(
            operationId: operationId,
            ownerId: conflict.ownerId,
            aggregateType: conflict.aggregateType,
            aggregateId: conflict.aggregateId,
            mutationKind: 'resolve_local',
            baseVersion: Value(conflict.remoteVersion),
            payloadJson: conflict.localJson,
            createdAt: DateTime.now().toUtc(),
          ),
        );
      } else {
        throw StateError('unsupported_conflict_aggregate');
      }
      await _database.conflictDao.beginResolution(
        conflictId,
        choice.name,
        operationId,
      );
    });
  }
}
