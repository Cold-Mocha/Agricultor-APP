import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/notifications/local_notification_scheduler.dart';
import 'package:agrocampo_backend/src/platform/notifications/reminder_notification_payload.dart';
import 'package:drift/drift.dart';

final class ReminderReconciler {
  ReminderReconciler(this._database, this._scheduler, this._payloadBuilder);
  final AppDatabase _database;
  final LocalNotificationScheduler _scheduler;
  final ReminderNotificationPayloadBuilder _payloadBuilder;

  Future<void> reconcile(String ownerId, {DateTime? now}) async {
    final instant = (now ?? DateTime.now()).toUtc();
    final rows =
        await (_database.select(_database.reminders)..where(
              (row) => row.ownerId.equals(ownerId) & row.deletedAt.isNull(),
            ))
            .get();
    for (final row in rows) {
      final notificationId =
          row.androidNotificationId ?? stableNotificationId(row.id);
      if (row.status != 'scheduled' || !row.scheduledAt.isAfter(instant)) {
        await _scheduler.cancel(notificationId);
        continue;
      }
      // A denied permission is a durable, truthful state. Reconciliation must
      // not silently turn it into "scheduled" until the user saves again and
      // grants the permission.
      if (row.notificationState == 'permissionDenied') continue;
      var state = 'scheduled';
      try {
        await _scheduler.schedule(
          id: notificationId,
          title: row.title,
          scheduledAt: row.scheduledAt,
          payload: _payloadBuilder(row.id),
        );
      } on Object {
        state = 'error';
      }
      await (_database.update(
        _database.reminders,
      )..where((value) => value.id.equals(row.id))).write(
        RemindersCompanion(
          androidNotificationId: Value(notificationId),
          notificationState: Value(state),
        ),
      );
    }
  }
}
