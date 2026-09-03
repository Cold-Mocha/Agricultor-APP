import 'dart:convert';

import 'package:agrocampo/core/sync/protocol/sector_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test(
    'sector pull requires parent and applies geometry/tombstone exactly',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      final parcelId = await ParcelRepository(database)
          .save(ownerId: 'owner-1', name: 'Campo');
      final codec = SectorSyncCodec();
      final payload = {
        'id': 'sector-1',
        'parcel_id': parcelId,
        'number': 1,
        'name': 'Norte',
        'kind': 'crop',
        'polygon': const [
          {'lat': -38.74, 'lng': -72.60},
          {'lat': -38.74, 'lng': -72.59},
          {'lat': -38.73, 'lng': -72.59},
        ],
        'updated_at': '2026-08-29T12:00:00Z',
        'deleted_at': '2026-08-29T13:00:00Z',
      };
      await codec.applyRemote(
        database,
        'owner-1',
        RemoteChange(
          sequence: 1,
          aggregateType: 'sector',
          aggregateId: 'sector-1',
          kind: 'delete',
          payloadJson: jsonEncode(payload),
          remoteVersion: 4,
        ),
      );
      final row = await database.select(database.sectors).getSingle();
      expect(row.parcelId, parcelId);
      expect(row.version, 4);
      expect(row.syncState, 'synced');
      expect(row.deletedAt, isNotNull);
    },
  );

  test('sector pull rejects missing parent without writing', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await expectLater(
      const SectorSyncCodec().applyRemote(
        database,
        'owner-1',
        RemoteChange(
          sequence: 1,
          aggregateType: 'sector',
          aggregateId: 'sector-1',
          kind: 'create',
          payloadJson: '{"id":"sector-1","parcel_id":"missing","number":1,"name":"Norte","polygon":[],"updated_at":"2026-08-29T12:00:00Z"}',
          remoteVersion: 1,
        ),
      ),
      throwsFormatException,
    );
    expect(await database.select(database.sectors).get(), isEmpty);
  });
}
