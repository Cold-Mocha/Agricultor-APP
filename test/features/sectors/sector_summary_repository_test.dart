import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/sectors/data/sector_summary_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test('quadrant summary projects only stored agricultural facts', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedAgriculturalContextFixture(database);
    await database
        .into(database.labors)
        .insert(
          LaborsCompanion.insert(
            id: 'labor-1',
            ownerId: 'owner-1',
            parcelId: 'parcel-1',
            sectorId: 'sector-1',
            type: 'fertilization',
            occurredAt: DateTime.utc(2026, 8, 20),
            updatedAt: DateTime.utc(2026, 8, 20),
          ),
        );
    await database
        .into(database.irrigationRecords)
        .insert(
          IrrigationRecordsCompanion.insert(
            id: 'irrigation-1',
            ownerId: 'owner-1',
            sectorId: 'sector-1',
            irrigationType: 'drip',
            soilTypeCode: 'unknown',
            irrigatedAt: DateTime.utc(2026, 8, 21),
            updatedAt: DateTime.utc(2026, 8, 21),
          ),
        );
    await database
        .into(database.soilMeasurements)
        .insert(
          SoilMeasurementsCompanion.insert(
            id: 'soil-1',
            ownerId: 'owner-1',
            sectorId: 'sector-1',
            moisturePercent: const Value(42),
            measuredAt: DateTime.utc(2026, 8, 22),
            updatedAt: DateTime.utc(2026, 8, 22),
          ),
        );

    final summaries = await SectorSummaryRepository(database)
        .watch(ownerId: 'owner-1', parcelId: 'parcel-1')
        .first;
    final summary = summaries.single;

    expect(summary.displayName, 'Cuadrante 1');
    expect(summary.cropLabel, 'Trigo');
    expect(summary.statusLabel, 'Cultivo activo');
    expect(summary.soilMoisturePercent, 42);
    expect(summary.lastIrrigationAt, DateTime.utc(2026, 8, 21));
    expect(summary.lastRecordAt, DateTime.utc(2026, 8, 22));
  });
}
