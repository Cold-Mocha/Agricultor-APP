import 'dart:convert';

import 'package:agrocampo/app/routing/app_routes.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo/core/sync/sync_request_hash.dart';
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
    String? id,
  }) async {
    input.validate(DateTime.now());
    await _validateContext(ownerId, input.parcelId, input.sectorId);
    final reminderId = id ?? EntityId.generate().value;
    final existing =
        await (_database.select(_database.reminders)..where(
              (row) => row.id.equals(reminderId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    final now = DateTime.now().toUtc();
    final version = (existing?.version ?? 0) + 1;
    final notificationId = stableNotificationId(reminderId);
    final payload = <String, Object?>{
      'id': reminderId,
      'parcel_id': input.parcelId,
      'sector_id': input.sectorId,
      'title': input.title.trim(),
      'description': input.description?.trim(),
      'notes': input.notes?.trim(),
      'scheduled_at': input.scheduledAt.toUtc().toIso8601String(),
      'source_time_zone': input.sourceTimeZone,
      'status': 'scheduled',
      'completed_at': null,
      'cancelled_at': null,
      'version': version,
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
    };
    final dependency = existing == null
        ? await _contextDependency(ownerId, input)
        : await _pending(ownerId, 'reminder', reminderId);
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () => _database
          .into(_database.reminders)
          .insertOnConflictUpdate(
            RemindersCompanion.insert(
              id: reminderId,
              ownerId: ownerId,
              parcelId: Value(input.parcelId),
              sectorId: Value(input.sectorId),
              title: input.title.trim(),
              description: Value(input.description?.trim()),
              notes: Value(input.notes?.trim()),
              scheduledAt: input.scheduledAt.toUtc(),
              sourceTimeZone: Value(input.sourceTimeZone),
              androidNotificationId: Value(notificationId),
              notificationState: const Value('pending_permission'),
              version: Value(version),
              updatedAt: now,
            ),
          ),
      operation: _operation(
        ownerId: ownerId,
        aggregateId: reminderId,
        mutation: existing == null ? 'create' : 'update',
        baseVersion: existing?.version,
        payload: payload,
        dependency: dependency,
        now: now,
      ),
    );
    await _schedulePersistingOutcome(
      reminderId,
      input.title,
      input.scheduledAt,
    );
    return reminderId;
  }

  Future<void> complete(String ownerId, String id) =>
      _setStatus(ownerId, id, 'completed');
  Future<void> cancel(String ownerId, String id) =>
      _setStatus(ownerId, id, 'cancelled');

  Future<void> _setStatus(String ownerId, String id, String status) async {
    final row =
        await (_database.select(_database.reminders)..where(
              (value) => value.id.equals(id) & value.ownerId.equals(ownerId),
            ))
            .getSingle();
    if (row.status != 'scheduled') return;
    final now = DateTime.now().toUtc();
    final version = row.version + 1;
    final payload = <String, Object?>{
      'id': row.id,
      'parcel_id': row.parcelId,
      'sector_id': row.sectorId,
      'title': row.title,
      'description': row.description,
      'notes': row.notes,
      'scheduled_at': row.scheduledAt.toIso8601String(),
      'source_time_zone': row.sourceTimeZone,
      'status': status,
      'completed_at': status == 'completed' ? now.toIso8601String() : null,
      'cancelled_at': status == 'cancelled' ? now.toIso8601String() : null,
      'version': version,
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
    };
    final dependency = await _pending(ownerId, 'reminder', id);
    await _database.syncOutboxDao.transactionWithOutbox<void>(
      writeAggregate: () =>
          (_database.update(
            _database.reminders,
          )..where((value) => value.id.equals(id))).write(
            RemindersCompanion(
              status: Value(status),
              isCompleted: Value(status == 'completed'),
              completedAt: Value(status == 'completed' ? now : null),
              cancelledAt: Value(status == 'cancelled' ? now : null),
              notificationState: const Value('cancelled'),
              version: Value(version),
              syncState: const Value('pending'),
              updatedAt: Value(now),
            ),
          ),
      operation: _operation(
        ownerId: ownerId,
        aggregateId: id,
        mutation: 'update',
        baseVersion: row.version,
        payload: payload,
        dependency: dependency,
        now: now,
      ),
    );
    await _scheduler.cancel(
      row.androidNotificationId ?? stableNotificationId(row.id),
    );
  }

  Future<void> _schedulePersistingOutcome(
    String id,
    String title,
    DateTime at,
  ) async {
    var state = 'scheduled';
    try {
      final permissionGranted = await _scheduler.requestPermission();
      if (!permissionGranted) {
        state = 'permissionDenied';
      } else {
        await _scheduler.schedule(
          id: stableNotificationId(id),
          title: title.trim(),
          scheduledAt: at,
          payload: AppRoutes.reminder(id),
        );
      }
    } on Object {
      state = 'error';
    }
    await (_database.update(_database.reminders)
          ..where((row) => row.id.equals(id)))
        .write(RemindersCompanion(notificationState: Value(state)));
  }

  SyncOutboxCompanion _operation({
    required String ownerId,
    required String aggregateId,
    required String mutation,
    required int? baseVersion,
    required Map<String, Object?> payload,
    required String? dependency,
    required DateTime now,
  }) => SyncOutboxCompanion.insert(
    operationId: EntityId.generate().value,
    ownerId: ownerId,
    aggregateType: 'reminder',
    aggregateId: aggregateId,
    mutationKind: mutation,
    baseVersion: Value(baseVersion),
    payloadJson: jsonEncode(payload),
    requestHash: Value(
      syncRequestHash(
        aggregateType: 'reminder',
        aggregateId: aggregateId,
        mutationKind: mutation,
        baseVersion: baseVersion,
        payload: payload,
      ),
    ),
    dependencyOperationId: Value(dependency),
    createdAt: now,
  );

  Future<void> _validateContext(
    String ownerId,
    String? parcelId,
    String? sectorId,
  ) async {
    if (parcelId == null && sectorId == null) return;
    if (parcelId == null) throw StateError('reminder_parcel_context_required');
    final parcel =
        await (_database.select(_database.parcels)..where(
              (row) => row.id.equals(parcelId) & row.ownerId.equals(ownerId),
            ))
            .getSingleOrNull();
    if (parcel == null) throw StateError('reminder_parcel_context_invalid');
    if (sectorId != null) {
      final sector =
          await (_database.select(_database.sectors)..where(
                (row) =>
                    row.id.equals(sectorId) &
                    row.ownerId.equals(ownerId) &
                    row.parcelId.equals(parcelId),
              ))
              .getSingleOrNull();
      if (sector == null) throw StateError('reminder_sector_context_invalid');
    }
  }

  Future<String?> _contextDependency(String ownerId, ReminderInput input) =>
      input.sectorId != null
      ? _pending(ownerId, 'sector', input.sectorId!)
      : input.parcelId != null
      ? _pending(ownerId, 'parcel', input.parcelId!)
      : Future.value();

  Future<String?> _pending(String ownerId, String type, String id) async {
    final rows =
        await (_database.select(_database.syncOutbox)
              ..where(
                (row) =>
                    row.ownerId.equals(ownerId) &
                    row.aggregateType.equals(type) &
                    row.aggregateId.equals(id) &
                    row.state.isNotIn(const ['done']),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
            .get();
    return rows.isEmpty ? null : rows.first.operationId;
  }
}
