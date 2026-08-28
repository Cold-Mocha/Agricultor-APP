import 'package:agrocampo/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo/features/reminders/data/reminder_repository.dart';
import 'package:agrocampo/features/reminders/domain/reminder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _Scheduler implements LocalNotificationScheduler {
  DateTime? scheduledAt;
  String? payload;

  @override
  Future<void> cancel(int id) async {}

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
    expect(scheduler.payload, '/recordatorios/$id');
  });

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
