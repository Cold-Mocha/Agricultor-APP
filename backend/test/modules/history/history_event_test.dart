import 'package:agrocampo_backend/src/modules/agricultural_context/contracts/dto/save_outcome.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/domain/entities/productive_domain.dart';
import 'package:agrocampo_backend/src/modules/history/domain/entities/history_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('history event keeps discriminated details and honest local state', () {
    final event = HistoryEvent(
      id: 'apiary-labor',
      groupingKey: 'labor:apiary-labor',
      type: HistoryEventType.labor,
      occurredAt: DateTime.utc(2026),
      title: 'Inspección apícola',
      sectorId: 'sector-apiary',
      syncState: 'conflict',
      category: ProductiveCategory.apiary,
      backupState: BackupState.conflict,
      details: const {'taskType': 'inspection', 'hiveCount': 4},
    );
    expect(event.details['taskType'], 'inspection');
    expect(event.details['hiveCount'], 4);
    expect(event.backupState, BackupState.conflict);
  });
}
