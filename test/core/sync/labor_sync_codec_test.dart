import 'dart:convert';

import 'package:agrocampo/core/sync/protocol/labor_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test('pull applies harvest root and production child atomically', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedAgriculturalContextFixture(database);
    final payload = <String, Object?>{
      'id': 'labor-remote',
      'parcel_id': 'parcel-1',
      'sector_id': 'sector-1',
      'agricultural_season_id': 'season-1',
      'crop_assignment_id': 'assignment-1',
      'type': 'harvest',
      'details': {
        'schemaVersion': 1,
        'type': 'harvest',
        'data': {'quantity': 10, 'unit': 'kg'},
      },
      'details_schema_version': 1,
      'status': 'recorded',
      'occurred_at': '2026-02-01T00:00:00Z',
      'updated_at': '2026-02-01T00:00:00Z',
      'production': {
        'id': 'production-remote',
        'labor_id': 'labor-remote',
        'crop_id': 'trigo',
        'quantity': 10,
        'unit': 'kg',
        'harvested_at': '2026-02-01T00:00:00Z',
      },
    };
    await const LaborSyncCodec().applyRemote(
      database,
      'owner-1',
      RemoteChange(
        sequence: 1,
        aggregateType: 'labor',
        aggregateId: 'labor-remote',
        kind: 'create',
        payloadJson: jsonEncode(payload),
        remoteVersion: 3,
      ),
    );
    expect(await database.select(database.labors).get(), hasLength(1));
    expect(
      await database.select(database.productionRecords).get(),
      hasLength(1),
    );
    expect((await database.select(database.labors).getSingle()).version, 3);
  });

  test('invalid child rolls back the labor root', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedAgriculturalContextFixture(database);
    final payload = {
      'id': 'bad',
      'parcel_id': 'parcel-1',
      'sector_id': 'sector-1',
      'agricultural_season_id': 'season-1',
      'crop_assignment_id': 'assignment-1',
      'type': 'harvest',
      'details': <String, Object?>{},
      'occurred_at': '2026-02-01T00:00:00Z',
      'updated_at': '2026-02-01T00:00:00Z',
      'production': {'id': 'p'},
    };
    await expectLater(
      const LaborSyncCodec().applyRemote(
        database,
        'owner-1',
        RemoteChange(
          sequence: 1,
          aggregateType: 'labor',
          aggregateId: 'bad',
          kind: 'create',
          payloadJson: jsonEncode(payload),
          remoteVersion: 1,
        ),
      ),
      throwsFormatException,
    );
    expect(await database.select(database.labors).get(), isEmpty);
  });
}
