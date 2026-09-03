import 'package:agrocampo/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo/features/reminders/data/reminder_repository.dart';
import 'package:agrocampo/features/reminders/domain/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _Scheduler implements LocalNotificationScheduler {
  DateTime? scheduledAt;
  String? payload;
  int? scheduledId;
  final cancelled = <int>[];
  bool fail = false;

  @override
  Future<void> cancel(int id) async => cancelled.add(id);

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
  }) async {
    if (fail) throw StateError('plugin_unavailable');
    scheduledId = id;
    this.scheduledAt = scheduledAt;
    this.payload = payload;
  }
}

void main() {
  test('persists reminder, outbox operation and local notification', () async {
    final database = createInMemoryDatabase();
    final scheduler = _Scheduler();
    addTearDown(database.close);
    final date = DateTime.now().add(const Duration(days: 1));

    final id = await ReminderRepository(database, scheduler).save(
      ownerId: 'owner-1',
      input: ReminderInput(title: 'Regar sector norte', scheduledAt: date),
    );

    expect(
      (await database.select(database.reminders).getSingle()).title,
      'Regar sector norte',
    );
    expect(await database.select(database.syncOutbox).get(), hasLength(1));
    expect(scheduler.scheduledAt, date);
    expect(scheduler.payload, '/mas/recordatorios/$id');
    expect(scheduler.scheduledId, stableNotificationId(id));
    expect(
      (await database.select(database.reminders).getSingle()).notificationState,
      'scheduled',
    );
  });

  test(
    'plugin failure keeps domain data and complete cancels stable binding',
    () async {
      final database = createInMemoryDatabase();
      final scheduler = _Scheduler()..fail = true;
      addTearDown(database.close);
      final repository = ReminderRepository(database, scheduler);
      final id = await repository.save(
        ownerId: 'owner-1',
        input: ReminderInput(
          title: 'Poda',
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        ),
      );
      expect(
        (await database.select(database.reminders).getSingle())
            .notificationState,
        'error',
      );
      scheduler.fail = false;
      await repository.complete('owner-1', id);
      final row = await database.select(database.reminders).getSingle();
      expect(row.status, 'completed');
      expect(scheduler.cancelled, [stableNotificationId(id)]);
      expect(await database.select(database.syncOutbox).get(), hasLength(2));
    },
  );

  test('rejects empty and past reminders', () {
    expect(
      () => ReminderInput(
        title: '',
        scheduledAt: DateTime.now(),
      ).validate(DateTime.now()),
      throwsArgumentError,
    );
  });
}
