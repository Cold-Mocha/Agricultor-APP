import 'package:agrocampo_backend/core/database/app_database.dart';
import 'package:agrocampo_backend/features/crops/domain/agricultural_season.dart';
import 'package:agrocampo_backend/features/crops/repositories/agricultural_season_repository.dart';
import 'package:agrocampo_backend/features/crops/repositories/crop_repository.dart';
import 'package:agrocampo_backend/features/crops/repositories/sector_crop_assignment_repository.dart';
import 'package:agrocampo_backend/features/irrigation/domain/irrigation_record.dart';
import 'package:agrocampo_backend/features/irrigation/repositories/irrigation_repository.dart';
import 'package:agrocampo_backend/features/labors/domain/labor_type.dart';
import 'package:agrocampo_backend/features/labors/repositories/labor_repository.dart';
import 'package:agrocampo_backend/features/soil/domain/soil_measurement.dart';
import 'package:agrocampo_backend/features/soil/repositories/soil_repository.dart';
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
    final seasonId = await AgriculturalSeasonRepository(database).save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      name: 'Temporada 2026',
      startsOn: DateTime.utc(2026),
      endsOn: DateTime.utc(2027),
      status: AgriculturalSeasonStatus.active,
    );
    final crops = CropRepository(database);
    final cropId = await crops.createCustom(
      ownerId: 'owner-1',
      name: 'Cultivo de prueba',
    );
    final assignments = SectorCropAssignmentRepository(database);
    final assignmentId = await assignments.plan(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      agriculturalSeasonId: seasonId,
      crop: await crops.getById(
        ownerId: 'owner-1',
        cropId: cropId,
        isCustom: true,
      ),
      effectiveFrom: DateTime.utc(2026),
    );
    await assignments.activate(
      ownerId: 'owner-1',
      assignmentId: assignmentId,
      effectiveAt: DateTime.utc(2026),
    );
    await LaborRepository(database).save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      seasonId: seasonId,
      cropAssignmentId: assignmentId,
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
