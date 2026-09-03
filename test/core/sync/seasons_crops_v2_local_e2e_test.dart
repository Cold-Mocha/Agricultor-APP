import 'dart:io';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/core/sync/protocol/supabase_sync_gateway.dart';
import 'package:agrocampo/core/sync/sync_coordinator.dart';
import 'package:agrocampo/features/crops/data/agricultural_season_repository.dart';
import 'package:agrocampo/features/crops/data/crop_exchange_repository.dart';
import 'package:agrocampo/features/crops/data/crop_repository.dart';
import 'package:agrocampo/features/crops/data/sector_crop_assignment_repository.dart';
import 'package:agrocampo/features/crops/domain/agricultural_season.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('seasons, custom crops and exchange reach a second file DB', () async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (url.isEmpty || anonKey.isEmpty) return;
    final client = SupabaseClient(
      url,
      anonKey,
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
    addTearDown(client.dispose);
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final auth = await client.auth.signUp(
      email: 'seasons-e2e-$suffix@agrocampo.local',
      password: 'AgroCampo-$suffix!',
    );
    final ownerId = auth.user!.id;

    final firstDirectory = await Directory.systemTemp.createTemp('crops-v2-a-');
    final firstFile = File(
      '${firstDirectory.path}${Platform.pathSeparator}db.sqlite',
    );
    var firstDb = AppDatabase.forTesting(NativeDatabase(firstFile));
    addTearDown(() async {
      await firstDb.close();
      await firstDirectory.delete(recursive: true);
    });
    final parcelId = await ParcelRepository(firstDb).save(
      ownerId: ownerId,
      name: 'Campo rotaciones',
      isActive: true,
      boundary: const [
        GeoPoint(-38.75, -72.61),
        GeoPoint(-38.75, -72.57),
        GeoPoint(-38.71, -72.57),
        GeoPoint(-38.71, -72.61),
      ],
    );
    final sectorIds = <String>[];
    for (var number = 1; number <= 2; number++) {
      sectorIds.add(
        await SectorRepository(firstDb).save(
          ownerId: ownerId,
          parcelId: parcelId,
          number: number,
          name: 'Sector $number',
          polygon: [
            GeoPoint(-38.74 + number * .002, -72.60),
            GeoPoint(-38.74 + number * .002, -72.59),
            GeoPoint(-38.735 + number * .002, -72.59),
            GeoPoint(-38.735 + number * .002, -72.60),
          ],
        ),
      );
    }
    final seasonId = await AgriculturalSeasonRepository(firstDb).save(
      ownerId: ownerId,
      parcelId: parcelId,
      name: '2026-27',
      startsOn: DateTime.utc(2026, 7),
      endsOn: DateTime.utc(2027, 6),
      status: AgriculturalSeasonStatus.active,
    );
    final crops = CropRepository(firstDb);
    final maizeId = await crops.createCustom(
      ownerId: ownerId,
      name: 'Maíz local',
    );
    final wheatId = await crops.createCustom(
      ownerId: ownerId,
      name: 'Trigo local',
    );
    final assignments = SectorCropAssignmentRepository(firstDb);
    final firstAssignment = await assignments.plan(
      ownerId: ownerId,
      sectorId: sectorIds[0],
      agriculturalSeasonId: seasonId,
      crop: await crops.getById(
        ownerId: ownerId,
        cropId: maizeId,
        isCustom: true,
      ),
      effectiveFrom: DateTime.utc(2026, 8),
    );
    final secondAssignment = await assignments.plan(
      ownerId: ownerId,
      sectorId: sectorIds[1],
      agriculturalSeasonId: seasonId,
      crop: await crops.getById(
        ownerId: ownerId,
        cropId: wheatId,
        isCustom: true,
      ),
      effectiveFrom: DateTime.utc(2026, 8),
    );
    await assignments.activate(
      ownerId: ownerId,
      assignmentId: firstAssignment,
      effectiveAt: DateTime.utc(2026, 8),
    );
    await assignments.activate(
      ownerId: ownerId,
      assignmentId: secondAssignment,
      effectiveAt: DateTime.utc(2026, 8),
    );
    await CropExchangeRepository(firstDb).exchange(
      ownerId: ownerId,
      firstSectorId: sectorIds[0],
      secondSectorId: sectorIds[1],
      effectiveAt: DateTime.utc(2026, 11),
    );

    await firstDb.close();
    firstDb = AppDatabase.forTesting(NativeDatabase(firstFile));
    final gateway = SupabaseSyncGateway(client);
    for (var cycle = 0; cycle < 20; cycle++) {
      await SyncCoordinator(firstDb, gateway).synchronize(ownerId);
      final pending = await (firstDb.select(
        firstDb.syncOutbox,
      )..where((row) => row.state.isNotIn(const ['done']))).get();
      if (pending.isEmpty) break;
    }
    expect(
      await (firstDb.select(
        firstDb.syncOutbox,
      )..where((row) => row.state.isNotIn(const ['done']))).get(),
      isEmpty,
    );

    final secondDirectory = await Directory.systemTemp.createTemp(
      'crops-v2-b-',
    );
    final secondFile = File(
      '${secondDirectory.path}${Platform.pathSeparator}db.sqlite',
    );
    final secondDb = AppDatabase.forTesting(NativeDatabase(secondFile));
    addTearDown(() async {
      await secondDb.close();
      await secondDirectory.delete(recursive: true);
    });
    await SyncCoordinator(secondDb, gateway).synchronize(ownerId);
    expect(
      await secondDb.select(secondDb.agriculturalSeasons).get(),
      hasLength(1),
    );
    expect(await secondDb.select(secondDb.customCrops).get(), hasLength(2));
    expect(await secondDb.select(secondDb.cropSeasons).get(), hasLength(4));
    final currentFirst = await SectorCropAssignmentRepository(secondDb)
        .activeAt(
          ownerId: ownerId,
          sectorId: sectorIds[0],
          instant: DateTime.utc(2026, 11, 2),
        );
    expect(currentFirst?.crop.id, wheatId);
  });
}
