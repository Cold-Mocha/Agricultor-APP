import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/history/data/history_repository.dart';
import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:agrocampo/features/production/data/production_repository.dart';
import 'package:agrocampo/features/production/domain/harvest_input.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('production appears immediately in filtered local history', (
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
            name: 'Sector',
            polygonJson: '[]',
            areaSquareMeters: 100,
            updatedAt: DateTime.utc(2026),
          ),
        );
    await ProductionRepository(database).save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      input: HarvestInput(
        cropId: 'trigo',
        quantity: 500,
        unit: 'kg',
        harvestedAt: DateTime.utc(2026),
      ),
    );
    final events = await HistoryRepository(database)
        .list(const HistoryFilter(ownerId: 'owner-1', parcelId: 'parcel-1'));
    expect(events.single.type, HistoryEventType.production);
  });
}
