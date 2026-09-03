import 'package:agrocampo/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo/core/notifications/reminder_reconciler.dart';
import 'package:agrocampo/features/reminders/data/reminder_repository.dart';
import 'package:agrocampo/features/reminders/domain/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _Scheduler implements LocalNotificationScheduler {
  final scheduled = <int>[];
  final cancelled = <int>[];
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required DateTime scheduledAt,
    String? payload,
  }) async => scheduled.add(id);
  @override
  Future<void> cancel(int id) async => cancelled.add(id);
}

void main() {
  test('stable notification id is reproducible and reconcile schedules future rows', () async {
    expect(
      stableNotificationId('reminder-1'),
      stableNotificationId('reminder-1'),
    );
    expect(
      stableNotificationId('reminder-1'),
      isNot(stableNotificationId('reminder-2')),
    );
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final scheduler = _Scheduler();
    await ReminderRepository(database, scheduler).save(
      ownerId: 'owner-1',
      input: ReminderInput(title: 'Regar', scheduledAt: DateTime.utc(2027)),
    );
    scheduler.scheduled.clear();
    await ReminderReconciler(
      database,
      scheduler,
    ).reconcile('owner-1', now: DateTime.utc(2026));
    expect(scheduler.scheduled, hasLength(1));
  });
}
