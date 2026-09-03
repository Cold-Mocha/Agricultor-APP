import 'dart:convert';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/agricultural_season_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/custom_crop_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sector_crop_assignment_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test(
    'season, custom crop and assignment apply in dependency order',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await _insertTerritory(database);
      await const AgriculturalSeasonSyncCodec().applyRemote(
        database,
        'owner-1',
        RemoteChange(
          sequence: 1,
          aggregateType: 'agriculturalSeason',
          aggregateId: 'season-1',
          kind: 'create',
          payloadJson: jsonEncode({
            'id': 'season-1',
            'parcel_id': 'parcel-1',
            'name': '2026-27',
            'starts_on': '2026-08-01T00:00:00Z',
            'ends_on': '2027-06-30T00:00:00Z',
            'status': 'active',
            'updated_at': '2026-08-01T00:00:00Z',
          }),
          remoteVersion: 1,
        ),
      );
      await const CustomCropSyncCodec().applyRemote(
        database,
        'owner-1',
        RemoteChange(
          sequence: 2,
          aggregateType: 'customCrop',
          aggregateId: 'crop-1',
          kind: 'archive',
          payloadJson: jsonEncode({
            'id': 'crop-1',
            'name': 'Ají local',
            'normalized_name': 'aji local',
            'archived_at': '2026-09-01T00:00:00Z',
            'updated_at': '2026-09-01T00:00:00Z',
          }),
          remoteVersion: 2,
        ),
      );
      await const SectorCropAssignmentSyncCodec().applyRemote(
        database,
        'owner-1',
        RemoteChange(
          sequence: 3,
          aggregateType: 'sectorCropAssignment',
          aggregateId: 'assignment-1',
          kind: 'create',
          payloadJson: jsonEncode({
            'id': 'assignment-1',
            'sector_id': 'sector-1',
            'agricultural_season_id': 'season-1',
            'crop_id': 'crop-1',
            'is_custom_crop': true,
            'status': 'ended',
            'starts_on': '2026-08-01T00:00:00Z',
            'ends_on': '2026-09-01T00:00:00Z',
            'updated_at': '2026-09-01T00:00:00Z',
          }),
          remoteVersion: 3,
        ),
      );

      expect(
        (await database.select(database.agriculturalSeasons).getSingle())
            .syncState,
        'synced',
      );
      expect(
        (await database.select(database.customCrops).getSingle()).archivedAt,
        isNotNull,
      );
      final assignment = await database
          .select(database.cropSeasons)
          .getSingle();
      expect(assignment.cropId, 'crop-1');
      expect(assignment.status, 'ended');
      expect(assignment.version, 3);
    },
  );

  test('assignment rejects absent season/crop without partial row', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await _insertTerritory(database);
    await expectLater(
      const SectorCropAssignmentSyncCodec().applyRemote(
        database,
        'owner-1',
        RemoteChange(
          sequence: 1,
          aggregateType: 'sectorCropAssignment',
          aggregateId: 'assignment-1',
          kind: 'create',
          payloadJson: '{"id":"assignment-1","sector_id":"sector-1","agricultural_season_id":"missing","crop_id":"missing","is_custom_crop":false,"status":"planned","starts_on":"2026-08-01T00:00:00Z","updated_at":"2026-08-01T00:00:00Z"}',
          remoteVersion: 1,
        ),
      ),
      throwsFormatException,
    );
    expect(await database.select(database.cropSeasons).get(), isEmpty);
  });
}

Future<void> _insertTerritory(AppDatabase database) async {
  await database
      .into(database.parcels)
      .insert(
        ParcelsCompanion.insert(
          id: 'parcel-1',
          ownerId: 'owner-1',
          name: 'Campo',
          updatedAt: DateTime.utc(2026),
        ),
      );
  await database
      .into(database.sectors)
      .insert(
        SectorsCompanion.insert(
          id: 'sector-1',
          ownerId: 'owner-1',
          parcelId: 'parcel-1',
          number: 1,
          name: 'Norte',
          polygonJson: '[]',
          areaSquareMeters: 100,
          updatedAt: DateTime.utc(2026),
        ),
      );
}
