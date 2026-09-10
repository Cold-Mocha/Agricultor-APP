import 'package:agrocampo_backend/src/modules/apiary/domain/entities/apiary_inspection_input.dart';
import 'package:agrocampo_backend/src/modules/apiary/infrastructure/persistence/apiary_repository.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/parcel_repository.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('apiary inspection is readable offline', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final parcelId = await ParcelRepository(
      database,
    ).save(ownerId: 'owner-1', name: 'Campo apícola de prueba', isActive: true);
    final sectorId = await SectorRepository(database).save(
      ownerId: 'owner-1',
      parcelId: parcelId,
      number: 1,
      name: 'Apiario de prueba',
      kind: 'apiary',
      polygon: const [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.73, -72.59),
      ],
    );
    await ApiaryRepository(database).save(
      ownerId: 'owner-1',
      sectorId: sectorId,
      input: ApiaryInspectionInput(
        taskType: ApiaryTaskType.inspection,
        beekeeperName: 'Responsable local',
        hiveCount: 8,
        queenStatus: 'Presente',
        broodStatus: 'Normal',
        feedingStatus: 'Normal',
        healthNotes: 'Sin hallazgos',
        pestNotes: 'Sin hallazgos',
        superInstalled: false,
        inspectedAt: DateTime.utc(2026, 8, 20),
      ),
    );
    expect(
      await database.select(database.apiaryInspections).get(),
      hasLength(1),
    );
  });
}
