import 'package:agrocampo_backend/src/modules/apiary/domain/entities/apiary_inspection_input.dart';
import 'package:agrocampo_backend/src/modules/apiary/infrastructure/persistence/apiary_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test('stores complete inspection and queues synchronization', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedTerritoryFixture(database);
    await (database.update(database.sectors)
          ..where((row) => row.id.equals('sector-1')))
        .write(const SectorsCompanion(kind: Value('apiary')));
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
    expect(
      (await database.customSelect(
        'SELECT labor_id FROM apiary_inspections WHERE id = ?',
        variables: [Variable(inspection.id)],
      ).getSingle()).read<String>('labor_id'),
      isNotEmpty,
    );
    expect(await database.select(database.labors).get(), hasLength(1));
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
