import 'dart:convert';

import 'package:agrocampo_backend/src/modules/apiary/domain/entities/apiary_inspection_input.dart';
import 'package:agrocampo_backend/src/modules/apiary/infrastructure/persistence/apiary_repository.dart';
import 'package:agrocampo_backend/src/modules/labors/infrastructure/sync/labor_sync_codec.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/sync_contract.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test('apiary compound payload retries into one root and specialization', () async {
    final source = createInMemoryDatabase();
    final target = createInMemoryDatabase();
    addTearDown(source.close);
    addTearDown(target.close);
    await seedTerritoryFixture(source);
    await seedTerritoryFixture(target);
    for (final database in [source, target]) {
      await database.customUpdate(
        'UPDATE sectors SET kind = ? WHERE id = ?',
        variables: [Variable<String>('apiary'), Variable<String>('sector-1')],
      );
    }
    await ApiaryRepository(source).save(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      input: ApiaryInspectionInput(
        taskType: ApiaryTaskType.feeding,
        beekeeperName: 'Ana',
        hiveCount: 4,
        queenStatus: 'no informado',
        broodStatus: 'no informado',
        feedingStatus: 'Jarabe',
        healthNotes: '',
        pestNotes: '',
        superInstalled: false,
        inspectedAt: DateTime.utc(2026, 8),
      ),
    );
    final operation = (await (source.select(source.syncOutbox)
          ..where((row) => row.aggregateType.equals('labor')))
        .getSingle());
    final payload = jsonDecode(operation.payloadJson) as Map<String, Object?>;
    await const LaborSyncCodec().applyRemote(
      target,
      'owner-1',
      RemoteChange(
        sequence: 1,
        aggregateType: 'labor',
        aggregateId: operation.aggregateId,
        kind: 'create',
        payloadJson: operation.payloadJson,
        remoteVersion: 1,
      ),
    );
    await const LaborSyncCodec().applyRemote(
      target,
      'owner-1',
      RemoteChange(
        sequence: 2,
        aggregateType: 'labor',
        aggregateId: operation.aggregateId,
        kind: 'create',
        payloadJson: operation.payloadJson,
        remoteVersion: 1,
      ),
    );
    expect(payload['domain_category'], 'apiary');
    expect(await target.select(target.labors).get(), hasLength(1));
    expect(await target.select(target.apiaryInspections).get(), hasLength(1));
  });
}
