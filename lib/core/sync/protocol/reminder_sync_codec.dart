import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo/core/sync/protocol/aggregate_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:drift/drift.dart';

final class ReminderSyncCodec implements AggregateSyncCodec {
  const ReminderSyncCodec();
  @override
  String get aggregateType => 'reminder';

  @override
  Future<void> applyRemote(
    AppDatabase database,
    String ownerId,
    RemoteChange change,
  ) async {
    final payload = jsonDecode(change.payloadJson);
    if (payload is! Map<String, Object?> ||
        payload['id'] != change.aggregateId ||
        payload['title'] is! String ||
        payload['scheduled_at'] is! String ||
        payload['status'] is! String ||
        payload['updated_at'] is! String) {
      throw const FormatException('reminder_payload_invalid');
    }
    final parcelId = payload['parcel_id'] as String?;
    final sectorId = payload['sector_id'] as String?;
    if (parcelId != null) {
      final parcel =
          await (database.select(database.parcels)..where(
                (row) => row.id.equals(parcelId) & row.ownerId.equals(ownerId),
              ))
              .getSingleOrNull();
      if (parcel == null) {
        throw const FormatException('reminder_parent_missing');
      }
    }
    if (sectorId != null) {
      final sector =
          await (database.select(database.sectors)..where(
                (row) =>
                    row.id.equals(sectorId) &
                    row.ownerId.equals(ownerId) &
                    (parcelId == null
                        ? const Constant(true)
                        : row.parcelId.equals(parcelId)),
              ))
              .getSingleOrNull();
      if (sector == null) {
        throw const FormatException('reminder_parent_missing');
      }
    }
    final status = payload['status']! as String;
    final updatedAt = DateTime.parse(payload['updated_at']! as String).toUtc();
    await database
        .into(database.reminders)
        .insertOnConflictUpdate(
          RemindersCompanion.insert(
            id: change.aggregateId,
            ownerId: ownerId,
            parcelId: Value(parcelId),
            sectorId: Value(sectorId),
            title: (payload['title']! as String).trim(),
            description: Value(payload['description'] as String?),
            notes: Value(payload['notes'] as String?),
            scheduledAt: DateTime.parse(payload['scheduled_at']! as String)
                .toUtc(),
            sourceTimeZone: Value(
              payload['source_time_zone'] as String? ?? 'UTC',
            ),
            status: Value(status),
            isCompleted: Value(status == 'completed'),
            completedAt: Value(_date(payload['completed_at'])),
            cancelledAt: Value(_date(payload['cancelled_at'])),
            androidNotificationId: Value(
              stableNotificationId(change.aggregateId),
            ),
            notificationState: const Value('pending_reconcile'),
            version: Value(change.remoteVersion),
            syncState: const Value('synced'),
            serverUpdatedAt: Value(updatedAt),
            deletedAt: Value(_date(payload['deleted_at'])),
            updatedAt: updatedAt,
          ),
        );
  }

  DateTime? _date(Object? value) =>
      value is String ? DateTime.parse(value).toUtc() : null;

  @override
  Future<void> markAcknowledged(
    AppDatabase database,
    String ownerId,
    String aggregateId,
    int? remoteVersion,
    DateTime acknowledgedAt,
  ) =>
      (database.update(database.reminders)..where(
            (row) => row.id.equals(aggregateId) & row.ownerId.equals(ownerId),
          ))
          .write(
            RemindersCompanion(
              version: remoteVersion == null
                  ? const Value.absent()
                  : Value(remoteVersion),
              syncState: const Value('synced'),
              serverUpdatedAt: Value(acknowledgedAt),
              lastSyncErrorCode: const Value(null),
            ),
          );
}
