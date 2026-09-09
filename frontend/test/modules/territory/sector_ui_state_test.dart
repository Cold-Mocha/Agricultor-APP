import 'package:agrocampo/src/modules/territory/presentation/formatters/sector_ui_mapper.dart';
import 'package:agrocampo/src/modules/territory/presentation/state/sector_ui_state.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
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
    );

    final state = SectorUiMapper.fromSummary(summary);

    expect(state, isA<SectorCardUiState>());
    expect(state.displayName, 'Cuadrante 1');
    expect(state.cropLabel, 'Trigo');
    expect(state.statusLabel, 'Cultivo activo');
  });

  test('history projection remains presentation-owned', () {
    final event = HistoryEvent(
      id: 'labor-1',
      groupingKey: 'labor-1',
      type: HistoryEventType.labor,
      occurredAt: DateTime.utc(2026, 8, 20),
      title: 'Fertilización',
      sectorId: 'sector-1',
      cropLabel: 'Trigo',
      syncState: 'pending',
    );

    final state = SectorUiMapper.fromHistory(event);

    expect(state.type, SectorHistoryType.labor);
    expect(state.cropLabel, 'Trigo');
  });
}
