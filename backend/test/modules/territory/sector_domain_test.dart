import 'package:agrocampo_backend/src/modules/territory/domain/entities/sector_geometry_draft.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const square = [
    GeoPoint(-38.74, -72.60),
    GeoPoint(-38.74, -72.59),
    GeoPoint(-38.73, -72.59),
    GeoPoint(-38.73, -72.60),
  ];

  test('draft has explicit editing and cancel states', () {
    final draft = SectorGeometryDraft(square);
    expect(draft.state, SectorGeometryDraftState.editing);
    draft.move(0, const GeoPoint(-38.741, -72.60));
    expect(draft.isDirty, isTrue);
    draft.cancel();
    expect(draft.state, SectorGeometryDraftState.cancelled);
    expect(draft.points, square);
    expect(() => draft.add(const GeoPoint(-38.72, -72.60)), throwsStateError);
  });

  test('confirm validates and closes the draft without changing source points', () {
    final source = [...square];
    final draft = SectorGeometryDraft(source);
    final confirmed = draft.confirm();
    expect(draft.state, SectorGeometryDraftState.confirmed);
    expect(confirmed, square);
    expect(source, square);
    expect(() => draft.remove(0), throwsStateError);
  });
}
