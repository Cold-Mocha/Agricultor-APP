import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:drift/drift.dart';

enum ConflictChoice { keepLocal, keepRemote }

final class ConflictResolver {
  ConflictResolver(this._database);

  final AppDatabase _database;

  Future<void> resolve(String conflictId, ConflictChoice choice) async {
    final conflict = await (_database.select(
      _database.syncConflicts,
    )..where((row) => row.conflictId.equals(conflictId))).getSingle();
    if (choice == ConflictChoice.keepLocal) {
      await _database.syncOutboxDao.enqueue(
        SyncOutboxCompanion.insert(
          operationId: '$conflictId-local-resolution',
          ownerId: conflict.ownerId,
          aggregateType: conflict.aggregateType,
          aggregateId: conflict.aggregateId,
          mutationKind: 'resolve_local',
          payloadJson: conflict.localJson,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    } else if (conflict.aggregateType == 'parcel') {
      final remote = jsonDecode(conflict.remoteJson) as Map<String, Object?>;
      await _database
          .into(_database.parcels)
          .insertOnConflictUpdate(
            ParcelsCompanion.insert(
              id: conflict.aggregateId,
              ownerId: conflict.ownerId,
              name: remote['name']! as String,
              locality: Value(remote['locality'] as String?),
              isActive: Value(remote['is_active'] as bool? ?? false),
              isArchived: Value(remote['is_archived'] as bool? ?? false),
              version: Value((remote['version'] as num?)?.toInt() ?? 1),
              updatedAt: DateTime.parse(remote['updated_at']! as String)
                  .toUtc(),
            ),
          );
    }
    await _database.conflictDao.markResolved(conflictId);
  }
}
