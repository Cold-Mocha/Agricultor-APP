import 'dart:io';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/core/sync/protocol/supabase_sync_gateway.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/core/sync/sync_coordinator.dart';
import 'package:agrocampo/core/sync/sync_gateway.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'parcel and dependent sector sync exact-once into a second DB',
    () async {
      const url = String.fromEnvironment('SUPABASE_URL');
      const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
      if (url.isEmpty || anonKey.isEmpty) return;
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
        email: 'territory-e2e-$suffix@agrocampo.local',
        password: 'AgroCampo-$suffix!',
      );
      final ownerId = auth.user!.id;
      expect(auth.session, isNotNull);

      final firstDirectory = await Directory.systemTemp.createTemp(
        'territory-v2-a-',
      );
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
        name: 'Campo local',
        isActive: true,
        boundary: const [
          GeoPoint(-38.75, -72.61),
          GeoPoint(-38.75, -72.57),
          GeoPoint(-38.71, -72.57),
          GeoPoint(-38.71, -72.61),
        ],
      );
      final sectorId = await SectorRepository(firstDb).save(
        ownerId: ownerId,
        parcelId: parcelId,
        number: 1,
        name: 'Norte',
        polygon: const [
          GeoPoint(-38.74, -72.60),
          GeoPoint(-38.74, -72.59),
          GeoPoint(-38.73, -72.59),
          GeoPoint(-38.73, -72.60),
        ],
      );
      final queued = await firstDb.select(firstDb.syncOutbox).get();
      expect(queued, hasLength(2));
      expect(
        queued
            .singleWhere((row) => row.aggregateType == 'sector')
            .dependencyOperationId,
        queued.singleWhere((row) => row.aggregateType == 'parcel').operationId,
      );

      await firstDb.close();
      firstDb = AppDatabase.forTesting(NativeDatabase(firstFile));
      final realGateway = SupabaseSyncGateway(client);
      await SyncCoordinator(firstDb, realGateway).synchronize(ownerId);
      expect(
        await client.from('parcels').select('id').eq('id', parcelId),
        hasLength(1),
      );
      expect(
        await client.from('sectors').select('id').eq('id', sectorId),
        isEmpty,
        reason: 'the dependent sector waits for the parcel ACK',
      );

      final lostAckGateway = _LoseFirstAckGateway(realGateway);
      await expectLater(
        SyncCoordinator(firstDb, lostAckGateway).synchronize(ownerId),
        throwsA(isA<StateError>()),
      );
      expect(
        await client.from('sectors').select('id').eq('id', sectorId),
        hasLength(1),
      );
      expect(
        (await firstDb.select(firstDb.syncOutbox).get())
            .singleWhere((row) => row.aggregateType == 'sector')
            .state,
        'pending',
      );

      await SyncCoordinator(firstDb, lostAckGateway).synchronize(ownerId);
      expect(
        await firstDb.select(firstDb.syncOutbox).get(),
        everyElement(
          isA<SyncOutboxData>().having((row) => row.state, 'state', 'done'),
        ),
      );
      expect(
        (await firstDb.select(firstDb.sectors).getSingle()).syncState,
        'synced',
      );

      final secondDirectory = await Directory.systemTemp.createTemp(
        'territory-v2-b-',
      );
      final secondFile = File(
        '${secondDirectory.path}${Platform.pathSeparator}db.sqlite',
      );
      final secondDb = AppDatabase.forTesting(NativeDatabase(secondFile));
      addTearDown(() async {
        await secondDb.close();
        await secondDirectory.delete(recursive: true);
      });
      await SyncCoordinator(secondDb, realGateway).synchronize(ownerId);
      final downloadedParcel = await secondDb
          .select(secondDb.parcels)
          .getSingle();
      final downloadedSector = await secondDb
          .select(secondDb.sectors)
          .getSingle();
      expect(downloadedParcel.id, parcelId);
      expect(downloadedSector.id, sectorId);
      expect(downloadedSector.parcelId, parcelId);
      expect(downloadedSector.areaSquareMeters, greaterThan(0));
    },
  );
}

final class _LoseFirstAckGateway implements SyncGateway {
  _LoseFirstAckGateway(this.delegate);

  final SyncGateway delegate;
  bool lost = false;

  @override
  Future<PullResult> pull({
    required String ownerId,
    required int afterCursor,
  }) => delegate.pull(ownerId: ownerId, afterCursor: afterCursor);

  @override
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  }) async {
    final response = await delegate.push(
      ownerId: ownerId,
      operations: operations,
    );
    if (!lost) {
      lost = true;
      throw StateError('simulated_ack_loss_after_remote_commit');
    }
    return response;
  }
}
