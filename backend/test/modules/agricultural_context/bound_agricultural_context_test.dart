import 'package:agrocampo_backend/src/modules/agricultural_context/domain/entities/agricultural_context.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/domain/entities/productive_domain.dart';
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
        category: ProductiveCategory.crop,
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
      expect(bound.category, ProductiveCategory.crop);
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

  test('bound context carries labels, capabilities and resolution instant', () {
    final resolved = DateTime.utc(2026, 9, 10);
    const context = AgriculturalContext(
      ownerId: 'owner-1',
      parcelId: 'parcel-a',
      sectorId: 'sector-a',
      category: ProductiveCategory.apiary,
      labels: ContextLabels(
        parcel: 'Parcela A',
        sector: 'Colmenar',
        category: 'Apícola',
      ),
      allowedOperations: [ProductiveOperation.apiaryInspection],
    );
    final bound = BoundAgriculturalContext.from(
      context,
      resolvedFor: resolved,
    );
    expect(bound.category, ProductiveCategory.apiary);
    expect(bound.labels.sector, 'Colmenar');
    expect(bound.allowedOperations, [ProductiveOperation.apiaryInspection]);
    expect(bound.resolvedFor, resolved);
  });
}
