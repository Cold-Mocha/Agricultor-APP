import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/irrigation/data/irrigation_repository.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_record.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/features/soil/data/soil_repository.dart';
import 'package:agrocampo/features/soil/domain/soil_measurement.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LABORES, soil and irrigation persist together offline', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.parcels)
        .insert(
          ParcelsCompanion.insert(
            id: 'parcel-1',
            ownerId: 'owner-1',
            name: 'Campo',
            updatedAt: DateTime.utc(2026),
          ),
        );
    await database
        .into(database.sectors)
        .insert(
          SectorsCompanion.insert(
            id: 'sector-1',
            ownerId: 'owner-1',
            parcelId: 'parcel-1',
            number: 1,
            name: 'Sector 1',
            polygonJson: '[]',
            areaSquareMeters: 100,
            updatedAt: DateTime.utc(2026),
          ),
        );
    await LaborRepository(database).save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      type: LaborType.other,
      customName: 'Mantención',
      notes: 'Reparación local',
      occurredAt: DateTime.utc(2026),
    );
    await SoilRepository(database).save(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      input: const SoilMeasurementInput(ph: 6.5),
    );
    await IrrigationRepository(database).saveBasic(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      input: const BasicIrrigationInput(
        type: IrrigationType.furrow,
        soilType: SoilType.clay,
        durationMinutes: 20,
      ),
    );

    expect(await database.select(database.labors).get(), hasLength(1));
    expect(
      await database.select(database.soilMeasurements).get(),
      hasLength(1),
    );
    expect(
      await database.select(database.irrigationRecords).get(),
      hasLength(1),
    );
  });
}
