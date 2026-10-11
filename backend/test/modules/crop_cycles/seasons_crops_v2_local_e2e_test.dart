import 'dart:io';

import 'package:agrocampo_backend/src/modules/crop_cycles/domain/entities/agricultural_season.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/agricultural_season_repository.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/crop_exchange_repository.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/crop_repository.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/sector_crop_assignment_repository.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/supabase_sync_gateway.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/local_supabase_e2e.dart';
import '../../helpers/sync_test_coordinator.dart';

void main() {
  test(
    'seasons, custom crops and exchange reach a second file DB',
    () async {
      requireLocalSupabaseE2e();
      const url = localSupabaseUrl;
      const anonKey = localSupabaseAnonKey;

      final client = SupabaseClient(
        url,
        anonKey,
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );
      addTearDown(client.dispose);
      final suffix = DateTime.now().microsecondsSinceEpoch;
      final auth = await client.auth.signUp(
        email: 'seasons-e2e-$suffix@example.invalid',
        password: 'AgroCampo-$suffix!',
      );
      final ownerId = auth.user!.id;

      final firstDirectory = await Directory.systemTemp.createTemp(
        'crops-v2-a-',
      );
      final firstFile = File(
        '${firstDirectory.path}${Platform.pathSeparator}db.sqlite',
      );
      var firstDb = AppDatabase.forTesting(NativeDatabase(firstFile));
      addTearDown(() async {
        await firstDb.close();
        await firstDirectory.delete(recursive: true);
      });
      final sectorIds = <String>[];
      for (var number = 1; number <= 2; number++) {
        sectorIds.add(
          await SectorRepository(firstDb).save(
            ownerId: ownerId,
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
      final seasonIds = [
        for (final sectorId in sectorIds)
          await AgriculturalSeasonRepository(firstDb).save(
            ownerId: ownerId,
            sectorId: sectorId,
            name: '2026-27',
            startsOn: DateTime.utc(2026, 7),
            endsOn: DateTime.utc(2027, 6),
            status: AgriculturalSeasonStatus.active,
          ),
      ];
      final seasonId = seasonIds.first;
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
        agriculturalSeasonId: seasonIds.last,
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
        await createTestSyncCoordinator(firstDb, gateway).synchronize(ownerId);
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
      await createTestSyncCoordinator(secondDb, gateway).synchronize(ownerId);
      final downloadedSeasons = await secondDb
          .select(secondDb.agriculturalSeasons)
          .get();
      expect(downloadedSeasons, hasLength(2));
      expect(downloadedSeasons.map((row) => row.id).toSet(), seasonIds.toSet());
      expect(
        {for (final row in downloadedSeasons) row.sectorId: row.id},
        {sectorIds.first: seasonIds.first, sectorIds.last: seasonIds.last},
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
      debugPrint(
        'REAL_E2E seasons owner=$ownerId seasons/custom crops SQLiteA/B verified',
      );
    },
    skip: !localSupabaseE2e
        ? 'Requires explicit disposable local Supabase E2E gate'
        : false,
  );
}
