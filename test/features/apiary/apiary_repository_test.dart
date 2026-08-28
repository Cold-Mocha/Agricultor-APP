import 'package:agrocampo/features/apiary/data/apiary_repository.dart';
import 'package:agrocampo/features/apiary/domain/apiary_inspection_input.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test('stores complete inspection and queues synchronization', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedTerritoryFixture(database);
    await ApiaryRepository(database).save(
      ownerId: 'owner-1',
      sectorId: 'sector-1',
      input: ApiaryInspectionInput(
        taskType: ApiaryTaskType.health,
        beekeeperName: 'Ana Pérez',
        hiveCount: 12,
        queenStatus: 'Visible',
        broodStatus: 'Uniforme',
        feedingStatus: 'Suficiente',
        healthNotes: 'Sin enfermedad visible',
        pestNotes: 'Sin varroa visible',
        superInstalled: true,
        inspectedAt: DateTime.utc(2026, 8, 20),
      ),
    );
    final inspection = await database
        .select(database.apiaryInspections)
        .getSingle();
    expect(inspection.taskType, 'health');
    expect(inspection.beekeeperName, 'Ana Pérez');
    expect(inspection.hiveCount, 12);
    expect(await database.select(database.syncOutbox).get(), hasLength(1));
  });

  test('rejects inspections without beekeeper or hives', () {
    expect(
      () => ApiaryInspectionInput(
        taskType: ApiaryTaskType.inspection,
        beekeeperName: '',
        hiveCount: 0,
        queenStatus: '',
        broodStatus: '',
        feedingStatus: '',
        healthNotes: '',
        pestNotes: '',
        superInstalled: false,
        inspectedAt: DateTime.now(),
      ).validate(),
      throwsArgumentError,
    );
  });
}
