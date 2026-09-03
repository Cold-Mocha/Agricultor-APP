import 'dart:convert';

import 'package:agrocampo/core/sync/protocol/irrigation_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/labor_sync_codec.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test('config then compound irrigation pull retains snapshot', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedAgriculturalContextFixture(database);
    final config = <String, Object?>{
      'id': 'config-1',
      'sector_id': 'sector-1',
      'method': 'drip',
      'plant_count': 100,
      'emitter_count': 200,
      'flow_ml_min': 4000,
      'effective_from': '2026-01-01T00:00:00Z',
      'config_version': 1,
      'updated_at': '2026-01-01T00:00:00Z',
    };
    await const IrrigationConfigSyncCodec().applyRemote(
      database,
      'owner-1',
      RemoteChange(
        sequence: 1,
        aggregateType: 'irrigationConfig',
        aggregateId: 'config-1',
        kind: 'create',
        payloadJson: jsonEncode(config),
        remoteVersion: 1,
      ),
    );
    final labor = <String, Object?>{
      'id': 'labor-water',
      'parcel_id': 'parcel-1',
      'sector_id': 'sector-1',
      'agricultural_season_id': 'season-1',
      'crop_assignment_id': 'assignment-1',
      'type': 'irrigation',
      'details': {
        'schemaVersion': 1,
        'type': 'irrigation',
        'data': {'method': 'drip'},
      },
      'occurred_at': '2026-02-01T00:00:00Z',
      'updated_at': '2026-02-01T00:00:00Z',
      'irrigation': {
        'id': 'record-1',
        'irrigation_type': 'drip',
        'soil_type_code': 'loamy',
        'config_id': 'config-1',
        'config_version': 1,
        'duration_seconds': 1800,
        'applied_volume_ml': 120000,
        'performed_details': {
          'config_snapshot': {'version': 1},
        },
        'irrigated_at': '2026-02-01T00:00:00Z',
      },
    };
    await const LaborSyncCodec().applyRemote(
      database,
      'owner-1',
      RemoteChange(
        sequence: 2,
        aggregateType: 'labor',
        aggregateId: 'labor-water',
        kind: 'create',
        payloadJson: jsonEncode(labor),
        remoteVersion: 1,
      ),
    );
    final record = await database
        .select(database.irrigationRecords)
        .getSingle();
    expect(record.configVersion, 1);
    expect(record.performedDetailsJson, contains('config_snapshot'));
    expect(await database.select(database.labors).get(), hasLength(1));
  });
}
