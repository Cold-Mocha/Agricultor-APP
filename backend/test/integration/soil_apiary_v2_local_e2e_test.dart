import 'dart:convert';

import 'package:agrocampo_backend/src/modules/apiary/domain/entities/apiary_inspection_input.dart';
import 'package:agrocampo_backend/src/modules/apiary/infrastructure/persistence/apiary_repository.dart';
import 'package:agrocampo_backend/src/modules/soil/domain/entities/soil_measurement.dart';
import 'package:agrocampo_backend/src/modules/soil/infrastructure/persistence/soil_repository.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/supabase_sync_gateway.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/sync_contract.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_gateway.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/file_backed_database.dart';
import '../helpers/local_supabase_e2e.dart';
import '../helpers/sync_test_coordinator.dart';

void main() {
  test(
    'real soil/apiary outbox survives Supabase and second SQLite DB with retries and cursor rollback',
    () async {
      requireLocalSupabaseE2e();
      final client = SupabaseClient(
        localSupabaseUrl,
        localSupabaseAnonKey,
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );
      addTearDown(client.dispose);
      final suffix = DateTime.now().microsecondsSinceEpoch;
      final auth = await client.auth.signUp(
        email: 'specialization-e2e-$suffix@example.invalid',
        password: 'Ficticio-$suffix!',
      );
      expect(auth.session, isNotNull);
      final owner = auth.user!.id;
      final fixtureA = await FileBackedDatabaseFixture.create();
      final fixtureB = await FileBackedDatabaseFixture.create();
      addTearDown(fixtureA.dispose);
      addTearDown(fixtureB.dispose);
      final first = fixtureA.open();
      var second = fixtureB.open();
      addTearDown(first.close);
      addTearDown(() => second.close());
      const polygon = [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.73, -72.59),
      ];
      final territory = SectorRepository(first);
      final crop = await territory.save(
        ownerId: owner,
        number: 1,
        name: 'FICTICIO suelo',
        polygon: polygon,
      );
      final apiary = await territory.save(
        ownerId: owner,
        number: 2,
        name: 'FICTICIO colmenas',
        polygon: polygon,
        kind: 'apiary',
      );
      final real = SupabaseSyncGateway(client);
      await createTestSyncCoordinator(first, real).synchronize(owner);
      final soilId = await SoilRepository(first).save(
        ownerId: owner,
        sectorId: crop,
        input: const SoilMeasurementInput(
          moisturePercent: 0,
          ph: 6.5,
          conductivity: 0,
          nitrogen: 0,
          phosphorus: 1.25,
          potassium: 2.5,
          units: {'moisturePercent': '%', 'conductivity': 'mS/cm'},
        ),
      );
      final apiaryId = await ApiaryRepository(first).save(
        ownerId: owner,
        sectorId: apiary,
        input: ApiaryInspectionInput(
          taskType: ApiaryTaskType.inspection,
          beekeeperName: 'FICTICIO',
          hiveCount: 3,
          queenStatus: 'ok',
          broodStatus: 'ok',
          feedingStatus: '',
          healthNotes: '',
          pestNotes: '',
          superInstalled: true,
          inspectedAt: DateTime.utc(2026, 10, 10),
          observations: null,
        ),
      );
      final queued = (await first.select(first.syncOutbox).get())
          .where((op) => op.aggregateType == 'labor')
          .toList();
      final result = await createTestSyncCoordinator(
        first,
        real,
      ).synchronize(owner);
      expect(result.pushed, 2);
      expect(
        await client.from('soil_measurements').select().eq('id', soilId),
        hasLength(1),
      );
      expect(
        await client.from('apiary_inspections').select().eq('id', apiaryId),
        hasLength(1),
      );
      final retry = await real.push(
        ownerId: owner,
        operations: queued
            .map(
              (op) => PushMutation(
                operationId: op.operationId,
                aggregateType: op.aggregateType,
                aggregateId: op.aggregateId,
                kind: op.mutationKind,
                payloadJson: op.payloadJson,
                requestHash: op.requestHash,
                baseVersion: op.baseVersion,
              ),
            )
            .toList(),
      );
      expect(
        retry.operations.map((op) => op.status),
        everyElement(PushOperationStatus.duplicate),
      );
      await expectLater(
        createTestSyncCoordinator(
          second,
          _InvalidSoilPull(real),
        ).synchronize(owner),
        throwsFormatException,
      );
      expect(await second.select(second.labors).get(), isEmpty);
      expect(await second.select(second.soilMeasurements).get(), isEmpty);
      expect(await second.syncCursorDao.read(owner, 'owner-changes-v1'), 0);
      await createTestSyncCoordinator(second, real).synchronize(owner);
      await second.close();
      second = fixtureB.open();
      final soil = await second.select(second.soilMeasurements).getSingle();
      expect(soil.id, soilId);
      expect(soil.laborId, isNotNull);
      expect(soil.moisturePercent, 0);
      expect(soil.ph, 6.5);
      expect(soil.temperatureCelsius, isNull);
      expect(soil.conductivity, 0);
      expect(soil.nitrogen, 0);
      expect(soil.phosphorus, 1.25);
      expect(soil.potassium, 2.5);
      final soilLabor = (await second.select(second.labors).get()).singleWhere(
        (l) => l.type == 'soil',
      );
      expect(soilLabor.id, soil.laborId);
      expect(soilLabor.seasonId, isNull);
      expect(soilLabor.cropAssignmentId, isNull);
      expect(soil.measuredAt, soilLabor.occurredAt);
      expect(jsonDecode(soilLabor.detailsJson)['data']['units'], {
        'moisturePercent': '%',
        'conductivity': 'mS/cm',
      });
      final inspection = await second
          .select(second.apiaryInspections)
          .getSingle();
      expect(inspection.id, apiaryId);
      expect(inspection.hiveCount, 3);
      expect(inspection.superInstalled, true);
      expect(inspection.observations, isNull);
      final categoryRows = await second
          .customSelect('SELECT type,domain_category FROM labors')
          .get();
      expect(
        {
          for (final row in categoryRows)
            row.read<String>('type'): row.read<String>('domain_category'),
        },
        {'soil': 'crop', 'apiary': 'apiary'},
      );
      final pulled = await createTestSyncCoordinator(
        second,
        real,
      ).synchronize(owner);
      expect(pulled.pulled, 0);
      expect(await second.select(second.labors).get(), hasLength(2));
      await SectorRepository(first).delete(ownerId: owner, id: crop);
      await createTestSyncCoordinator(first, real).synchronize(owner);
      await createTestSyncCoordinator(second, real).synchronize(owner);
      expect(
        (await second.select(second.sectors).get())
            .singleWhere((row) => row.id == crop)
            .deletedAt,
        isNotNull,
      );
      expect(await second.select(second.soilMeasurements).get(), hasLength(1));
      expect(await second.select(second.labors).get(), hasLength(2));
      debugPrint(
        'REAL_E2E owner=$owner remote soil=1 apiary=1 local roots=2 children=2 cursor rollback/retry verified',
      );
    },
    skip: !localSupabaseE2e
        ? 'Requires explicit disposable local Supabase E2E gate'
        : false,
  );
}

final class _InvalidSoilPull implements SyncGateway {
  const _InvalidSoilPull(this.delegate);
  final SyncGateway delegate;
  @override
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  }) => delegate.push(ownerId: ownerId, operations: operations);
  @override
  Future<PullResult> pull({
    required String ownerId,
    required int afterCursor,
  }) async {
    final pull = await delegate.pull(
      ownerId: ownerId,
      afterCursor: afterCursor,
    );
    return PullResult(
      changes: pull.changes.map((change) {
        if (change.aggregateType != 'labor') return change;
        final payload = jsonDecode(change.payloadJson) as Map<String, Object?>;
        if (payload['type'] != 'soil') return change;
        payload['soil'] = {
          ...(payload['soil']! as Map<String, Object?>),
          'ph': 15,
        };
        return RemoteChange(
          sequence: change.sequence,
          aggregateType: change.aggregateType,
          aggregateId: change.aggregateId,
          kind: change.kind,
          payloadJson: jsonEncode(payload),
          remoteVersion: change.remoteVersion,
        );
      }).toList(),
      nextCursor: pull.nextCursor,
      conflicts: pull.conflicts,
    );
  }
}
