import 'dart:convert';

import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/parcel_repository.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/database/owner_transfer.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_request_hash.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  const localOwner = 'local-owner';
  const remoteOwner = 'remote-owner';
  const triangle = [
    GeoPoint(-38.74, -72.60),
    GeoPoint(-38.74, -72.59),
    GeoPoint(-38.73, -72.59),
  ];

  Future<void> seedLocalData(AppDatabase database) async {
    final parcelId = await ParcelRepository(database)
        .save(ownerId: localOwner, name: 'Campo');
    await SectorRepository(database).saveConfirmed(
      ownerId: localOwner,
      parcelId: parcelId,
      number: 1,
      name: 'Paltos',
      kind: 'crop',
      polygon: triangle,
    );
    await database
        .into(database.localProfiles)
        .insert(
          LocalProfilesCompanion.insert(
            id: localOwner,
            displayName: 'Agricultor',
            updatedAt: DateTime.utc(2026),
          ),
        );
  }

  test(
    'moves records, profile and pending operations to the new owner',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await seedLocalData(database);

      await OwnerTransfer(database).transfer(from: localOwner, to: remoteOwner);

      final parcels = await database.select(database.parcels).get();
      final sectors = await database.select(database.sectors).get();
      final outbox = await database.select(database.syncOutbox).get();
      final profiles = await database.select(database.localProfiles).get();
      expect(parcels.map((row) => row.ownerId), everyElement(remoteOwner));
      expect(sectors.map((row) => row.ownerId), everyElement(remoteOwner));
      expect(profiles.single.id, remoteOwner);
      expect(outbox, isNotEmpty);
      for (final row in outbox) {
        expect(row.ownerId, remoteOwner);
        expect(row.payloadJson, isNot(contains(localOwner)));
        expect(
          row.requestHash,
          syncRequestHash(
            aggregateType: row.aggregateType,
            aggregateId: row.aggregateId,
            mutationKind: row.mutationKind,
            baseVersion: row.baseVersion,
            payload: jsonDecode(row.payloadJson) as Object,
          ),
        );
      }
    },
  );

  test('keeps the target owner preference when both owners have one', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    for (final (owner, value) in [
      (localOwner, 'local'),
      (remoteOwner, 'remote'),
    ]) {
      await database
          .into(database.appPreferences)
          .insert(
            AppPreferencesCompanion.insert(
              ownerId: owner,
              key: 'selected_parcel',
              value: value,
              updatedAt: DateTime.utc(2026),
            ),
          );
    }

    await OwnerTransfer(database).transfer(from: localOwner, to: remoteOwner);

    final preferences = await database.select(database.appPreferences).get();
    expect(preferences.single.ownerId, remoteOwner);
    expect(preferences.single.value, 'remote');
  });
}
