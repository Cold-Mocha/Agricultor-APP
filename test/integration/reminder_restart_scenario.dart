import 'package:agrocampo/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo/core/notifications/reminder_reconciler.dart';
import 'package:agrocampo/features/reminders/data/reminder_repository.dart';
import 'package:agrocampo/features/reminders/domain/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/file_backed_database.dart';

final class _Scheduler implements LocalNotificationScheduler {
  _Scheduler({this.permissionGranted = true, this.failSchedule = false});
  bool permissionGranted;
  bool failSchedule;
  final scheduled = <int>[];
  final cancelled = <int>[];
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => permissionGranted;
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    if (failSchedule) throw StateError('native_plugin_unavailable');
    scheduled.add(id);
  }

  @override
  Future<void> cancel(int id) async => cancelled.add(id);
}

void main() {
  test('30 reminders persist through three restarts and reconcile deterministically', () async {
    final fixture = await FileBackedDatabaseFixture.create();
    addTearDown(fixture.dispose);
    var database = fixture.open();
    addTearDown(() => database.close());
    final reminderIds = <String>[];
    for (var index = 0; index < 30; index++) {
      final scheduler = index < 10
          ? _Scheduler(permissionGranted: false)
          : index < 20
          ? _Scheduler(failSchedule: true)
          : _Scheduler();
      final reminderId = await ReminderRepository(database, scheduler).save(
        ownerId: 'owner-1',
        id: 'reminder-$index',
        input: ReminderInput(
          title: 'Labor programada $index',
          scheduledAt: DateTime.now().add(Duration(days: 2, minutes: index)),
        ),
      );
      reminderIds.add(reminderId);
    }
    expect(await database.select(database.reminders).get(), hasLength(30));
    final initial = await database.select(database.reminders).get();
    expect(
      initial.where((row) => row.notificationState == 'permissionDenied'),
      hasLength(10),
    );
    expect(
      initial.where((row) => row.notificationState == 'error'),
      hasLength(10),
    );
    expect(
      initial.where((row) => row.notificationState == 'scheduled'),
      hasLength(10),
    );

    for (var restart = 1; restart <= 3; restart++) {
      await database.close();
      database = fixture.open();
      final recoveredScheduler = _Scheduler();
      await ReminderReconciler(
        database,
        recoveredScheduler,
      ).reconcile('owner-1');
      final recovered = await database.select(database.reminders).get();
      expect(recovered, hasLength(30));
      expect(
        recovered.where((row) => row.notificationState == 'permissionDenied'),
        hasLength(10),
      );
      expect(recoveredScheduler.scheduled.toSet(), {
        for (final id in reminderIds.skip(10)) stableNotificationId(id),
      });
    }

    final stateScheduler = _Scheduler();
    final repository = ReminderRepository(database, stateScheduler);
    for (final id in reminderIds.take(10)) {
      await repository.complete('owner-1', id);
    }
    for (final id in reminderIds.skip(10).take(10)) {
      await repository.cancel('owner-1', id);
    }

    await database.close();
    database = fixture.open();
    final finalScheduler = _Scheduler();
    await ReminderReconciler(database, finalScheduler).reconcile('owner-1');
    final finalRows = await database.select(database.reminders).get();
    expect(finalRows, hasLength(30));
    expect(finalRows.where((row) => row.status == 'completed'), hasLength(10));
    expect(finalRows.where((row) => row.status == 'cancelled'), hasLength(10));
    expect(finalRows.where((row) => row.status == 'scheduled'), hasLength(10));
    expect(finalScheduler.scheduled, hasLength(10));
    expect(finalScheduler.cancelled, hasLength(20));
    expect(await database.select(database.syncOutbox).get(), hasLength(50));
  });
}
