import 'package:agrocampo/features/context/domain/agricultural_context.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'an open flow keeps its route-bound sector after global context changes',
    () {
      const initial = AgriculturalContext(
        ownerId: 'owner-1',
        parcelId: 'parcel-a',
        sectorId: 'sector-a',
        seasonId: 'season-a',
        assignmentId: 'assignment-a',
        revision: 4,
      );
      final bound = BoundAgriculturalContext.from(initial);
      const changed = AgriculturalContext(
        ownerId: 'owner-1',
        parcelId: 'parcel-b',
        sectorId: 'sector-b',
        seasonId: 'season-b',
        assignmentId: 'assignment-b',
        revision: 5,
      );

      expect(bound.differsFrom(changed), isTrue);
      expect(bound.parcelId, 'parcel-a');
      expect(bound.sectorId, 'sector-a');
      expect(bound.seasonId, 'season-a');
      expect(bound.assignmentId, 'assignment-a');
    },
  );

  test('an explicit route sector overrides only the sector binding', () {
    const context = AgriculturalContext(
      ownerId: 'owner-1',
      parcelId: 'parcel-a',
      sectorId: 'sector-a',
      seasonId: 'season-a',
      assignmentId: 'assignment-a',
      revision: 4,
    );

    final bound = BoundAgriculturalContext.from(
      context,
      sectorId: 'sector-route',
    );

    expect(bound.parcelId, 'parcel-a');
    expect(bound.sectorId, 'sector-route');
    expect(bound.seasonId, 'season-a');
  });
}
