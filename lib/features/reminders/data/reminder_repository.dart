import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo/features/reminders/domain/reminder.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:drift/drift.dart';

final class ReminderRepository {
  ReminderRepository(this._database, this._scheduler);

  final AppDatabase _database;
  final LocalNotificationScheduler _scheduler;

  Future<String> save({
    required String ownerId,
    required ReminderInput input,
  }) async {
    input.validate(DateTime.now());
    final id = EntityId.generate().value;
    final now = DateTime.now().toUtc();
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database
          .into(_database.reminders)
          .insert(
            RemindersCompanion.insert(
              id: id,
              ownerId: ownerId,
              sectorId: Value(input.sectorId),
              title: input.title.trim(),
              notes: Value(input.notes?.trim()),
              scheduledAt: input.scheduledAt.toUtc(),
              updatedAt: now,
            ),
          ),
      operation: SyncOutboxCompanion.insert(
        operationId: EntityId.generate().value,
        ownerId: ownerId,
        aggregateType: 'reminder',
        aggregateId: id,
        mutationKind: 'create',
        payloadJson: jsonEncode({
          'id': id,
          'title': input.title,
          'scheduled_at': input.scheduledAt.toUtc().toIso8601String(),
        }),
        createdAt: now,
      ),
    );
    await _scheduler.schedule(
      id: id.hashCode,
      title: input.title.trim(),
      scheduledAt: input.scheduledAt,
      payload: '/recordatorios/$id',
    );
    return id;
  }
}
