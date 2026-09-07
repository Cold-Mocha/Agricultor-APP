import 'package:agrocampo_backend/features/history/domain/history_event.dart';
import 'package:agrocampo_backend/features/sectors/dto/sector_ui_state.dart';
import 'package:agrocampo_backend/features/sectors/repositories/sector_summary_repository.dart';
import 'package:agrocampo_backend/features/sectors/services/sector_ui_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sector mapper exposes a display contract without data models', () {
    final summary = SectorSummary(
      id: 'sector-1',
      parcelId: 'parcel-1',
      number: 1,
      kind: 'crop',
      areaSquareMeters: 100,
      polygonJson: '[]',
      syncState: 'pending',
      cropLabel: 'Trigo',
      cropIconAsset: 'wheat',
      cropColorToken: 'cropWheat',
      assignmentStatus: 'active',
      lastIrrigationAt: DateTime.utc(2026, 8, 21),
    );

    final state = SectorUiMapper.fromSummary(summary);

    expect(state, isA<SectorCardUiState>());
    expect(state.displayName, 'Cuadrante 1');
    expect(state.cropLabel, 'Trigo');
    expect(state.statusLabel, 'Cultivo activo');
    expect(state.syncState, 'pending');
    expect(state.lastRecordAt, DateTime.utc(2026, 8, 21));
  });

  test('history mapper preserves the navigation identity', () {
    final event = HistoryEvent(
      id: 'labor-1',
      groupingKey: 'labor:labor-1',
      type: HistoryEventType.labor,
      occurredAt: DateTime.utc(2026, 8, 22),
      title: 'Fertilización',
      sectorId: 'sector-1',
      cropLabel: 'Trigo',
      syncState: 'local',
    );

    final state = SectorUiMapper.fromHistory(event);

    expect(state.type, SectorHistoryType.labor);
    expect(state.groupingKey, 'labor:labor-1');
    expect(state.sectorId, 'sector-1');
    expect(state.cropLabel, 'Trigo');
  });
}
