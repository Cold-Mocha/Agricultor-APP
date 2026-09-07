import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/core/notifications/local_notification_scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_database.dart';
import '../helpers/territory_fixture.dart';

final class _DeniedNotifications implements LocalNotificationScheduler {
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => false;
  @override
  Future<void> cancel(int id) async {}
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required DateTime scheduledAt,
    String? payload,
  }) async => throw StateError('notifications_permission_denied');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'public crop and map queries isolate owners and preserve season dates',
    () async {
      final database = createInMemoryDatabase();
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(database.close);
      addTearDown(container.dispose);
      await seedAgriculturalContextFixture(database);

      final crops = container.read(cropsControllerProvider);
      final season = await crops.loadSeason(ownerId: 'owner-1', id: 'season-1');
      expect(season?.status, AgriculturalSeasonStatus.active);
      expect(season?.startsOn, DateTime.utc(2025));
      expect(
        await crops.loadSeason(ownerId: 'other-owner', id: 'season-1'),
        isNull,
      );
      final options = await crops.planOptions(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
      );
      expect(options?.season.id, 'season-1');
      expect(options?.crops.map((crop) => crop.label), contains('Trigo'));

      final map = container.read(territoryMapControllerProvider);
      expect(
        (await map.watchSectors(ownerId: 'owner-1', parcelId: 'parcel-1').first)
            .single
            .id,
        'sector-1',
      );
      expect(
        await map
            .watchSectors(ownerId: 'other-owner', parcelId: 'parcel-1')
            .first,
        isEmpty,
      );
    },
  );

  test(
    'AgroIA API preserves the failed question and retry identity offline',
    () async {
      final database = createInMemoryDatabase();
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(database.close);
      addTearDown(container.dispose);
      final ai = container.read(agroAiControllerProvider);

      await expectLater(
        ai.ask(ownerId: 'owner-1', question: 'Cómo cuidar el cultivo'),
        throwsStateError,
      );
      final question = (await ai.watchMessages('owner-1').first).single;
      expect(question.content, 'Cómo cuidar el cultivo');
      expect(question.state, 'error');
      await expectLater(
        ai.retry(ownerId: 'owner-1', clientMessageId: question.clientMessageId),
        throwsStateError,
      );
      final afterRetry = (await ai.watchMessages('owner-1').first).single;
      expect(afterRetry.clientMessageId, question.clientMessageId);
      expect(afterRetry.state, 'error');
      expect(await ai.watchMessages('other-owner').first, isEmpty);
    },
  );

  test(
    'reminder API retains local data when notification permission is denied',
    () async {
      final database = createInMemoryDatabase();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          localNotificationSchedulerProvider.overrideWithValue(
            _DeniedNotifications(),
          ),
        ],
      );
      addTearDown(database.close);
      addTearDown(container.dispose);
      final reminders = container.read(remindersControllerProvider);

      final id = await reminders.save(
        ownerId: 'owner-1',
        input: ReminderInput(
          title: 'Revisar riego',
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        ),
      );
      final saved = (await reminders.watch('owner-1').first).single;
      expect(saved.id, id);
      expect(saved.title, 'Revisar riego');
      expect(saved.notificationState, 'permissionDenied');
      expect(saved.syncState, 'pending');
      await reminders.complete('owner-1', id);
      expect(
        (await reminders.watch('owner-1').first).single.status,
        'completed',
      );
      expect(await reminders.watch('other-owner').first, isEmpty);
    },
  );
}
