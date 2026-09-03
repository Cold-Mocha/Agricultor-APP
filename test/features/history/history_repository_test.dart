import 'package:agrocampo/features/history/data/history_repository.dart';
import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/fertilization_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/features/labors/domain/pruning_details.dart';
import 'package:agrocampo/features/production/data/production_repository.dart';
import 'package:agrocampo/features/production/domain/harvest_input.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test('history filters events by parcel and orders newest first', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedAgriculturalContextFixture(database);
    final labors = LaborRepository(database);
    await labors.save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      type: LaborType.pruning,
      occurredAt: DateTime.utc(2026, 1),
      details: const PruningDetails(method: 'Manual').toEnvelope(),
    );
    await labors.save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      type: LaborType.fertilization,
      occurredAt: DateTime.utc(2026, 2),
      details: const FertilizationDetails(
        product: 'Compost',
        amount: 10,
        unit: 'kg',
        applicationMethod: 'Banda',
      ).toEnvelope(),
    );
    final events = await HistoryRepository(database).list(
      const HistoryFilter(
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        sectorId: 'sector-1',
        type: HistoryEventType.labor,
      ),
    );
    expect(events, hasLength(2));
    expect(events.first.title, 'Fertilización');
    expect(events.map((event) => event.groupingKey).toSet(), hasLength(2));
  });

  test(
    'harvest production decorates one labor event instead of duplicating it',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await seedAgriculturalContextFixture(database);
      await ProductionRepository(database).save(
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        sectorId: 'sector-1',
        input: HarvestInput(
          cropId: 'trigo',
          quantity: 25,
          unit: 'kg',
          harvestedAt: DateTime.utc(2026, 2),
        ),
      );
      final events = await HistoryRepository(database).list(
        const HistoryFilter(
          ownerId: 'owner-1',
          sectorId: 'sector-1',
          type: HistoryEventType.labor,
        ),
      );
      expect(events, hasLength(1));
      expect(events.single.title, 'Cosecha');
      expect(events.single.detail, contains('25'));
      expect(events.single.cropLabel, 'Trigo');
    },
  );
}
