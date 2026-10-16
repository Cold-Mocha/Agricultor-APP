import 'package:agrocampo_backend/src/modules/agricultural_context/contracts/dto/save_outcome.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/domain/entities/productive_domain.dart';
import 'package:agrocampo_backend/src/modules/history/domain/entities/history_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('history contract separates grouping, category and backup state', () {
    final event = HistoryEvent(
      id: 'labor-1',
      groupingKey: 'labor:labor-1',
      type: HistoryEventType.labor,
      occurredAt: DateTime.utc(2026),
      title: 'Riego',
      sectorId: 'sector-1',
      syncState: 'pending',
      category: ProductiveCategory.crop,
      backupState: BackupState.pending,
      details: const {'pressureKpa': 80},
    );
    expect(event.groupingKey, 'labor:labor-1');
    expect(event.category, ProductiveCategory.crop);
    expect(event.details['pressureKpa'], 80);
    expect(event.backupState, BackupState.pending);
  });

  test('history filters expose stable pagination and category selector', () {
    const filter = HistoryFilter(
      ownerId: 'owner-1',
      category: ProductiveCategory.apiary,
      limit: 20,
      offset: 40,
    );
    expect(filter.category, ProductiveCategory.apiary);
    expect(filter.limit, 20);
    expect(filter.offset, 40);
  });
}
