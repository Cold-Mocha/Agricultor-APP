import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/crops/data/agricultural_season_repository.dart';
import 'package:agrocampo/features/crops/data/crop_assignment_reconciler.dart';
import 'package:agrocampo/features/crops/data/crop_exchange_repository.dart';
import 'package:agrocampo/features/crops/data/sector_crop_assignment_repository.dart';
import 'package:agrocampo/features/crops/domain/agricultural_season.dart';
import 'package:agrocampo/features/crops/domain/crop_ref.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/fertilization_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test(
    'future rotation activates at its exact date and preserves previous row',
    () async {
      final fixture = await _fixture();
      addTearDown(fixture.database.close);
      final repository = SectorCropAssignmentRepository(fixture.database);
      final first = await repository.plan(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        agriculturalSeasonId: fixture.seasonId,
        crop: fixture.maize,
        effectiveFrom: DateTime.utc(2026, 8, 1),
      );
      await repository.activate(
        ownerId: 'owner-1',
        assignmentId: first,
        effectiveAt: DateTime.utc(2026, 8, 1),
      );
      final future = await repository.plan(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        agriculturalSeasonId: fixture.seasonId,
        crop: fixture.wheat,
        effectiveFrom: DateTime.utc(2026, 10, 3),
      );
      expect(
        (await repository.activeAt(
          ownerId: 'owner-1',
          sectorId: 'sector-1',
          instant: DateTime.utc(2026, 9),
        ))?.crop.id,
        'maiz',
      );
      expect(
        await CropAssignmentReconciler(fixture.database)
            .reconcile('owner-1', now: DateTime.utc(2026, 10, 3)),
        1,
      );
      final rows = await fixture.database
          .select(fixture.database.cropSeasons)
          .get();
      expect(
        rows.singleWhere((row) => row.id == first).endsOn,
        DateTime.utc(2026, 10, 3),
      );
      expect(
        rows.singleWhere((row) => row.id == future).startsOn,
        DateTime.utc(2026, 10, 3),
      );
      expect(rows.singleWhere((row) => row.id == future).status, 'active');
    },
  );

  test(
    'two-sector exchange is all-or-nothing and keeps historical assignments',
    () async {
      final fixture = await _fixture();
      addTearDown(fixture.database.close);
      final repository = SectorCropAssignmentRepository(fixture.database);
      final first = await repository.plan(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        agriculturalSeasonId: fixture.seasonId,
        crop: fixture.maize,
        effectiveFrom: DateTime.utc(2026, 8, 1),
      );
      final second = await repository.plan(
        ownerId: 'owner-1',
        sectorId: 'sector-2',
        agriculturalSeasonId: fixture.seasonId,
        crop: fixture.wheat,
        effectiveFrom: DateTime.utc(2026, 8, 1),
      );
      await repository.activate(
        ownerId: 'owner-1',
        assignmentId: first,
        effectiveAt: DateTime.utc(2026, 8, 1),
      );
      await repository.activate(
        ownerId: 'owner-1',
        assignmentId: second,
        effectiveAt: DateTime.utc(2026, 8, 1),
      );

      await CropExchangeRepository(fixture.database).exchange(
        ownerId: 'owner-1',
        firstSectorId: 'sector-1',
        secondSectorId: 'sector-2',
        effectiveAt: DateTime.utc(2026, 11, 1),
      );

      expect(
        (await repository.activeAt(
          ownerId: 'owner-1',
          sectorId: 'sector-1',
          instant: DateTime.utc(2026, 11, 2),
        ))?.crop.id,
        'trigo',
      );
      expect(
        (await repository.activeAt(
          ownerId: 'owner-1',
          sectorId: 'sector-2',
          instant: DateTime.utc(2026, 11, 2),
        ))?.crop.id,
        'maiz',
      );
      expect(
        await fixture.database.select(fixture.database.cropSeasons).get(),
        hasLength(4),
      );
    },
  );

  test(
    '20 rotations preserve every event sector crop and season relationship',
    () async {
      final fixture = await _fixture();
      addTearDown(fixture.database.close);
      final assignments = SectorCropAssignmentRepository(fixture.database);
      final labors = LaborRepository(fixture.database);
      final start = DateTime.utc(2026, 8, 1);
      var activeAssignment = await assignments.plan(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        agriculturalSeasonId: fixture.seasonId,
        crop: fixture.maize,
        effectiveFrom: start,
      );
      await assignments.activate(
        ownerId: 'owner-1',
        assignmentId: activeAssignment,
        effectiveAt: start,
      );
      final expectedAssignmentByLabor = <String, String>{};

      for (var rotation = 0; rotation < 20; rotation++) {
        final effectiveAt = start.add(Duration(days: rotation + 1));
        final before = await labors.save(
          ownerId: 'owner-1',
          parcelId: 'parcel-1',
          sectorId: 'sector-1',
          seasonId: fixture.seasonId,
          cropAssignmentId: activeAssignment,
          type: LaborType.fertilization,
          occurredAt: effectiveAt.subtract(const Duration(hours: 1)),
          details: const FertilizationDetails(
            product: 'Compost',
            amount: 1,
            unit: 'kg',
            applicationMethod: 'Banda',
          ).toEnvelope(),
        );
        expectedAssignmentByLabor[before] = activeAssignment;

        final nextAssignment = await assignments.plan(
          ownerId: 'owner-1',
          sectorId: 'sector-1',
          agriculturalSeasonId: fixture.seasonId,
          crop: rotation.isEven ? fixture.wheat : fixture.maize,
          effectiveFrom: effectiveAt,
        );
        await assignments.activate(
          ownerId: 'owner-1',
          assignmentId: nextAssignment,
          effectiveAt: effectiveAt,
        );
        final after = await labors.save(
          ownerId: 'owner-1',
          parcelId: 'parcel-1',
          sectorId: 'sector-1',
          seasonId: fixture.seasonId,
          cropAssignmentId: nextAssignment,
          type: LaborType.fertilization,
          occurredAt: effectiveAt.add(const Duration(hours: 1)),
          details: const FertilizationDetails(
            product: 'Compost',
            amount: 1,
            unit: 'kg',
            applicationMethod: 'Banda',
          ).toEnvelope(),
        );
        expectedAssignmentByLabor[after] = nextAssignment;
        activeAssignment = nextAssignment;
      }

      final assignmentRows = {
        for (final row
            in await fixture.database
                .select(fixture.database.cropSeasons)
                .get())
          row.id: row,
      };
      final laborRows = await fixture.database
          .select(fixture.database.labors)
          .get();
      expect(assignmentRows, hasLength(21));
      expect(laborRows, hasLength(40));
      for (final labor in laborRows) {
        final expectedAssignment = expectedAssignmentByLabor[labor.id];
        expect(labor.parcelId, 'parcel-1');
        expect(labor.sectorId, 'sector-1');
        expect(labor.seasonId, fixture.seasonId);
        expect(labor.cropAssignmentId, expectedAssignment);
        final assignment = assignmentRows[expectedAssignment];
        expect(assignment, isNotNull);
        expect(assignment!.sectorId, labor.sectorId);
        expect(assignment.agriculturalSeasonId, labor.seasonId);
      }
    },
  );
}

final class _CropFixture {
  const _CropFixture({
    required this.database,
    required this.seasonId,
    required this.maize,
    required this.wheat,
  });

  final AppDatabase database;
  final String seasonId;
  final CropRef maize;
  final CropRef wheat;
}

Future<_CropFixture> _fixture() async {
  final database = createInMemoryDatabase();
  await database
      .into(database.parcels)
      .insert(
        ParcelsCompanion.insert(
          id: 'parcel-1',
          ownerId: 'owner-1',
          name: 'Campo',
          updatedAt: DateTime.utc(2026),
        ),
      );
  for (var number = 1; number <= 2; number++) {
    await database
        .into(database.sectors)
        .insert(
          SectorsCompanion.insert(
            id: 'sector-$number',
            ownerId: 'owner-1',
            parcelId: 'parcel-1',
            number: number,
            name: 'Sector $number',
            polygonJson: '[]',
            areaSquareMeters: 100,
            updatedAt: DateTime.utc(2026),
          ),
        );
  }
  for (final crop in const [('maiz', 'Maíz'), ('trigo', 'Trigo')]) {
    await database
        .into(database.officialCrops)
        .insert(
          OfficialCropsCompanion.insert(
            id: crop.$1,
            commonName: crop.$2,
            category: 'cereal',
            colorToken: 'cropCereal',
            iconAsset: 'assets/icons/crops/custom-crop.svg',
          ),
        );
  }
  final seasonId = await AgriculturalSeasonRepository(database).save(
    ownerId: 'owner-1',
    parcelId: 'parcel-1',
    name: '2026-27',
    startsOn: DateTime.utc(2026, 7),
    endsOn: DateTime.utc(2027, 6),
    status: AgriculturalSeasonStatus.active,
  );
  return _CropFixture(
    database: database,
    seasonId: seasonId,
    maize: const CropRef(
      id: 'maiz',
      label: 'Maíz',
      source: CropSource.official,
    ),
    wheat: const CropRef(
      id: 'trigo',
      label: 'Trigo',
      source: CropSource.official,
    ),
  );
}
