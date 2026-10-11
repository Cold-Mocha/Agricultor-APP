import 'dart:convert';
import 'dart:io';

import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/supabase_sync_gateway.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/sync_contract.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_gateway.dart';
import 'package:agrocampo_backend/src/shared/kernel/entity_id.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/local_supabase_e2e.dart';
import '../../helpers/sync_test_coordinator.dart';

void main() {
  test(
    'sector syncs exact-once into a second DB without a parent',
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
        email: 'territory-e2e-$suffix@example.invalid',
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
      final sectorId = await SectorRepository(firstDb).save(
        ownerId: ownerId,
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
      expect(queued, hasLength(1));
      expect(queued.single.aggregateType, 'sector');
      expect(queued.single.dependencyOperationId, isNull);

      await firstDb.close();
      firstDb = AppDatabase.forTesting(NativeDatabase(firstFile));
      final realGateway = SupabaseSyncGateway(client);
      final lostAckGateway = _LoseFirstAckGateway(realGateway);
      await expectLater(
        createTestSyncCoordinator(firstDb, lostAckGateway).synchronize(ownerId),
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

      await createTestSyncCoordinator(
        firstDb,
        lostAckGateway,
      ).synchronize(ownerId);
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
      await createTestSyncCoordinator(
        secondDb,
        realGateway,
      ).synchronize(ownerId);
      final downloadedSector = await secondDb
          .select(secondDb.sectors)
          .getSingle();
      expect(downloadedSector.id, sectorId);
      expect(downloadedSector.areaSquareMeters, greaterThan(0));
      await SectorRepository(firstDb).delete(ownerId: ownerId, id: sectorId);
      await createTestSyncCoordinator(
        firstDb,
        realGateway,
      ).synchronize(ownerId);
      final legacyId = EntityId.generate().value;
      final legacyOperation = EntityId.generate().value;
      final legacyPayload =
          jsonDecode(queued.single.payloadJson) as Map<String, Object?>;
      legacyPayload['id'] = legacyId;
      legacyPayload['deleted_at'] = null;
      await firstDb
          .into(firstDb.sectors)
          .insert(
            SectorsCompanion.insert(
              id: legacyId,
              ownerId: ownerId,
              number: 1,
              name: 'Legado duplicado ficticio',
              polygonJson: downloadedSector.polygonJson,
              areaSquareMeters: downloadedSector.areaSquareMeters,
              updatedAt: DateTime.now().toUtc(),
            ),
          );
      await firstDb
          .into(firstDb.syncOutbox)
          .insert(
            SyncOutboxCompanion.insert(
              operationId: legacyOperation,
              ownerId: ownerId,
              aggregateType: 'sector',
              aggregateId: legacyId,
              mutationKind: 'create',
              payloadJson: jsonEncode(legacyPayload),
              createdAt: DateTime.now().toUtc(),
            ),
          );
      await createTestSyncCoordinator(
        firstDb,
        realGateway,
      ).synchronize(ownerId);
      final legacyRows = await firstDb.select(firstDb.sectors).get();
      expect(legacyRows.map((row) => row.id).toSet(), {sectorId, legacyId});
      expect(legacyRows.map((row) => row.number).toList(), [1, 1]);
      expect(
        legacyRows.singleWhere((row) => row.id == sectorId).deletedAt,
        isNotNull,
      );
      expect(
        legacyRows.singleWhere((row) => row.id == legacyId).deletedAt,
        isNull,
      );
      final rejected = (await firstDb.select(firstDb.syncOutbox).get())
          .singleWhere((row) => row.operationId == legacyOperation);
      expect(rejected.state, 'failed');
      expect(rejected.lastErrorCode, 'uniqueness_conflict');
      expect(
        await client.from('sectors').select('id').eq('id', legacyId),
        isEmpty,
      );
      expect(
        await client
            .from('sync_operations')
            .select('operation_id')
            .eq('operation_id', legacyOperation),
        isEmpty,
      );
      debugPrint(
        'REAL_E2E territory owner=$ownerId SQLiteA/B remote ACK retry, legacy duplicate rejected without renumber/data loss',
      );
    },
    skip: !localSupabaseE2e
        ? 'Requires explicit disposable local Supabase E2E gate'
        : false,
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
