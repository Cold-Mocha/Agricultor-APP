import 'package:agrocampo/features/history/data/history_repository.dart';
import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test('history filters events by parcel and orders newest first', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedTerritoryFixture(database);
    final labors = LaborRepository(database);
    await labors.save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      type: LaborType.pruning,
      occurredAt: DateTime.utc(2026, 1),
    );
    await labors.save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      type: LaborType.harvest,
      occurredAt: DateTime.utc(2026, 2),
    );
    final events = await HistoryRepository(database)
        .list(const HistoryFilter(ownerId: 'owner-1', parcelId: 'parcel-1'));
    expect(events, hasLength(2));
    expect(events.first.title, 'harvest');
  });
}
