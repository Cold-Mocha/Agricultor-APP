import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/apiary/data/apiary_repository.dart';
import 'package:agrocampo/features/apiary/domain/apiary_inspection_input.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('apiary inspection is readable offline', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await ApiaryRepository(database).save(
      ownerId: 'owner-1',
      sectorId: 'apiary-sector',
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
