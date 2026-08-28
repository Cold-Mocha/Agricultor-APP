import 'dart:io';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/files/private_file_store.dart';
import 'package:agrocampo/core/notifications/local_notification_scheduler.dart';
import 'package:agrocampo/features/photos/data/photo_repository.dart';
import 'package:agrocampo/features/photos/domain/photo_attachment.dart';
import 'package:agrocampo/features/reminders/data/reminder_repository.dart';
import 'package:agrocampo/features/reminders/domain/reminder.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final class _FileStore implements FileStore {
  _FileStore(this.directory);
  final Directory directory;

  @override
  Future<String> import(String sourcePath, String ownerId, String fileName) =>
      File(sourcePath)
          .copy('${directory.path}/$fileName')
          .then((file) => file.path);
}

final class _Scheduler implements LocalNotificationScheduler {
  bool scheduled = false;
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
    scheduled = true;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('photo and reminder remain available in the local database', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final directory = await Directory.systemTemp.createTemp('agrocampo-us6');
    addTearDown(database.close);
    addTearDown(() => directory.delete(recursive: true));
    final source = File('${directory.path}/photo.jpg');
    await source.writeAsBytes([10, 20, 30]);
    await PhotoRepository(database, _FileStore(directory)).attach(
      PhotoAttachmentInput(
        ownerId: 'owner-1',
        aggregateType: 'sector',
        aggregateId: 'sector-1',
        sourcePath: source.path,
        mimeType: 'image/jpeg',
      ),
    );
    final scheduler = _Scheduler();
    await ReminderRepository(database, scheduler).save(
      ownerId: 'owner-1',
      input: ReminderInput(
        title: 'Revisar riego',
        scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      ),
    );

    expect(
      await database.select(database.photoAttachments).get(),
      hasLength(1),
    );
    expect(await database.select(database.reminders).get(), hasLength(1));
    expect(scheduler.scheduled, isTrue);
  });
}
