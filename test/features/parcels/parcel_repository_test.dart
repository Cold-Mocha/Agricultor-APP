import 'dart:convert';

import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('only one parcel remains active and every save queues outbox', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final repository = ParcelRepository(database);
    await repository.save(ownerId: 'owner-1', name: 'Norte', isActive: true);
    await repository.save(ownerId: 'owner-1', name: 'Sur', isActive: true);

    final parcels = await database.select(database.parcels).get();
    expect(parcels.where((parcel) => parcel.isActive), hasLength(1));
    expect(await database.select(database.syncOutbox).get(), hasLength(2));
  });

  test(
    'archive updates entity and complete outbox payload atomically',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      final repository = ParcelRepository(database);
      final id = await repository.save(
        ownerId: 'owner-1',
        name: 'Norte',
        isActive: true,
      );
      await database.delete(database.syncOutbox).go();

      await repository.archive(ownerId: 'owner-1', id: id, archived: true);

      final parcel = await database.select(database.parcels).getSingle();
      final outbox = await database.select(database.syncOutbox).getSingle();
      final payload = jsonDecode(outbox.payloadJson) as Map<String, Object?>;
      expect(parcel.isArchived, isTrue);
      expect(parcel.isActive, isFalse);
      expect(payload['is_archived'], isTrue);
      expect(payload['is_active'], isFalse);
      expect(outbox.requestHash, hasLength(64));
    },
  );

  test(
    'delete of never-synced empty parcel cancels its pending create',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      final repository = ParcelRepository(database);
      final id = await repository.save(ownerId: 'owner-1', name: 'Temporal');

      expect(
        await repository.deleteIfEmpty(ownerId: 'owner-1', id: id),
        isTrue,
      );
      expect(await database.select(database.syncOutbox).get(), isEmpty);
      expect(
        (await database.select(database.parcels).getSingle()).deletedAt,
        isNotNull,
      );
    },
  );
}
