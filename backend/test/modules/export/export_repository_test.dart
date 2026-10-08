import 'package:agrocampo_backend/src/modules/export/infrastructure/persistence/export_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('deleted sectors and everything under them are left out', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final now = DateTime.utc(2026, 1, 1);

    await database
        .into(database.sectors)
        .insert(
          SectorsCompanion.insert(
            id: 'sector-kept',
            ownerId: 'owner-1',
            number: 1,
            name: 'Sector vigente',
            polygonJson: '[]',
            areaSquareMeters: 100,
            updatedAt: now,
          ),
        );
    await database
        .into(database.sectors)
        .insert(
          SectorsCompanion.insert(
            id: 'sector-deleted',
            ownerId: 'owner-1',
            number: 2,
            name: 'Sector eliminado',
            polygonJson: '[]',
            areaSquareMeters: 50,
            updatedAt: now,
            deletedAt: Value(now),
          ),
        );

    await database
        .into(database.labors)
        .insert(
          LaborsCompanion.insert(
            id: 'labor-kept',
            ownerId: 'owner-1',
            sectorId: 'sector-kept',
            type: 'pruning',
            occurredAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.labors)
        .insert(
          LaborsCompanion.insert(
            id: 'labor-under-deleted-sector',
            ownerId: 'owner-1',
            sectorId: 'sector-deleted',
            type: 'pruning',
            occurredAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.labors)
        .insert(
          LaborsCompanion.insert(
            id: 'labor-soft-deleted',
            ownerId: 'owner-1',
            sectorId: 'sector-kept',
            type: 'pruning',
            occurredAt: now,
            updatedAt: now,
            deletedAt: Value(now),
          ),
        );

    await database
        .into(database.soilMeasurements)
        .insert(
          SoilMeasurementsCompanion.insert(
            id: 'soil-under-deleted-sector',
            ownerId: 'owner-1',
            sectorId: 'sector-deleted',
            measuredAt: now,
            updatedAt: now,
          ),
        );

    final snapshot = await ExportRepository(database).snapshot('owner-1');

    final sectorIds = snapshot.sheets['sectores']!.map((row) => row['id']);
    expect(sectorIds, contains('sector-kept'));
    expect(sectorIds, isNot(contains('sector-deleted')));

    final laborIds = snapshot.sheets['labores']!.map((row) => row['id']);
    expect(laborIds, contains('labor-kept'));
    expect(laborIds, isNot(contains('labor-under-deleted-sector')));
    expect(laborIds, isNot(contains('labor-soft-deleted')));

    expect(snapshot.sheets['suelo'], isEmpty);
  });

  test('exports the fields added by recent labor/irrigation formats', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final now = DateTime.utc(2026, 1, 1);

    await database
        .into(database.sectors)
        .insert(
          SectorsCompanion.insert(
            id: 'sector-1',
            ownerId: 'owner-1',
            number: 1,
            name: 'Sector 1',
            kind: const Value('apiary'),
            polygonJson: '[]',
            areaSquareMeters: 100,
            updatedAt: now,
          ),
        );
    await database
        .into(database.labors)
        .insert(
          LaborsCompanion.insert(
            id: 'labor-1',
            ownerId: 'owner-1',
            sectorId: 'sector-1',
            type: 'apiary',
            domainCategory: const Value('apiary'),
            notes: const Value('Revisión de rutina'),
            occurredAt: now,
            updatedAt: now,
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
            soilTypeCode: 'loam',
            durationSeconds: const Value(1800),
            appliedVolumeMl: const Value(5000),
            irrigatedAt: now,
            updatedAt: now,
          ),
        );

    final snapshot = await ExportRepository(database).snapshot('owner-1');

    final labor = snapshot.sheets['labores']!.single;
    expect(labor['categoria_dominio'], 'apiary');
    expect(labor['notas'], 'Revisión de rutina');
    expect(labor['estado'], 'recorded');

    final irrigation = snapshot.sheets['riego']!.single;
    expect(irrigation['duracion_seg'], 1800);
    expect(irrigation['volumen_aplicado_ml'], 5000);
  });
}
