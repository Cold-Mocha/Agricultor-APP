import 'package:agrocampo/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = createInMemoryDatabase());
  tearDown(() => database.close());

  test('creates the technical schema and persists a local profile', () async {
    await database
        .into(database.localProfiles)
        .insert(
          LocalProfilesCompanion.insert(
            id: 'owner-1',
            displayName: 'Agricultora local',
            updatedAt: DateTime.utc(2026),
          ),
        );

    final profile = await database.select(database.localProfiles).getSingle();
    expect(profile.id, 'owner-1');
    expect(profile.locale, 'es_CL');
  });

  test('aggregate and outbox writes roll back as one transaction', () async {
    final operation = SyncOutboxCompanion.insert(
      operationId: 'op-1',
      ownerId: 'owner-1',
      aggregateType: 'profile',
      aggregateId: 'owner-1',
      mutationKind: 'upsert',
      payloadJson: '{}',
      createdAt: DateTime.utc(2026),
    );

    await expectLater(
      database.syncOutboxDao.transactionWithOutbox<void>(
        writeAggregate: () async {
          await database
              .into(database.localProfiles)
              .insert(
                LocalProfilesCompanion.insert(
                  id: 'owner-1',
                  displayName: 'Temporal',
                  updatedAt: DateTime.utc(2026),
                ),
              );
          throw StateError('forced rollback');
        },
        operation: operation,
      ),
      throwsStateError,
    );

    expect(await database.select(database.localProfiles).get(), isEmpty);
    expect(await database.select(database.syncOutbox).get(), isEmpty);
  });
}
