import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('history events retain historical labels, grouping and sync state', () {
    final event = HistoryEvent(
      id: 'labor-1',
      groupingKey: 'labor:labor-1',
      type: HistoryEventType.labor,
      occurredAt: DateTime.utc(2026, 3),
      title: 'Cosecha',
      sectorId: 'sector-1',
      seasonId: 'season-1',
      seasonLabel: 'Temporada 2025/26',
      cropLabel: 'Trigo',
      detail: '450 kg',
      syncState: 'pending',
    );
    expect(event.groupingKey, 'labor:labor-1');
    expect(event.seasonLabel, 'Temporada 2025/26');
    expect(event.cropLabel, 'Trigo');
    expect(event.syncState, 'pending');
  });
}
