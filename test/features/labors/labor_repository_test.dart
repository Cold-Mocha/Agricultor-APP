import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/fertilization_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/features/labors/domain/other_labor_details.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test('Otra labor requires descriptive name and observations', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedAgriculturalContextFixture(database);
    final repository = LaborRepository(database);

    await expectLater(
      repository.save(
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        sectorId: 'sector-1',
        type: LaborType.other,
        occurredAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
    await repository.save(
      ownerId: 'owner-1',
      parcelId: 'parcel-1',
      sectorId: 'sector-1',
      type: LaborType.other,
      customName: 'Reparar cerco',
      notes: 'Tramo norte',
      details: const OtherLaborDetails(
        name: 'Reparar cerco',
        description: 'Tramo norte',
      ).toEnvelope(),
      occurredAt: DateTime.utc(2026),
    );
    expect(
      (await database.select(database.labors).getSingle()).customName,
      'Reparar cerco',
    );
  });

  test(
    'requires structured details, context and makes double submit idempotent',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await seedAgriculturalContextFixture(database);
      final repository = LaborRepository(database);

      await expectLater(
        repository.save(
          ownerId: 'owner-1',
          parcelId: 'parcel-1',
          sectorId: 'sector-1',
          type: LaborType.fertilization,
          occurredAt: DateTime.utc(2026, 2),
        ),
        throwsArgumentError,
      );
      final id = await repository.save(
        id: 'labor-1',
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        sectorId: 'sector-1',
        type: LaborType.fertilization,
        occurredAt: DateTime.utc(2026, 2),
        details: const FertilizationDetails(
          product: 'Compost',
          amount: 20,
          unit: 'kg',
          applicationMethod: 'Banda',
        ).toEnvelope(),
      );
      expect(
        await repository.save(
          id: 'labor-1',
          ownerId: 'owner-1',
          parcelId: 'parcel-1',
          sectorId: 'sector-1',
          type: LaborType.fertilization,
          occurredAt: DateTime.utc(2026, 2),
          details: const FertilizationDetails(
            product: 'Compost',
            amount: 20,
            unit: 'kg',
            applicationMethod: 'Banda',
          ).toEnvelope(),
        ),
        id,
      );
      expect(await database.select(database.labors).get(), hasLength(1));
      expect(await database.select(database.syncOutbox).get(), hasLength(1));
    },
  );

  test(
    'correction never silently moves a labor to a newer crop assignment',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await seedAgriculturalContextFixture(database);
      final repository = LaborRepository(database);
      final originalId = await repository.save(
        ownerId: 'owner-1',
        parcelId: 'parcel-1',
        sectorId: 'sector-1',
        type: LaborType.fertilization,
        occurredAt: DateTime.utc(2026, 2),
        details: const FertilizationDetails(
          product: 'Compost',
          amount: 20,
          unit: 'kg',
          applicationMethod: 'Banda',
        ).toEnvelope(),
      );
      await (database.update(
        database.cropSeasons,
      )..where((row) => row.id.equals('assignment-1'))).write(
        CropSeasonsCompanion(
          status: const Value('ended'),
          endsOn: Value(DateTime.utc(2026, 4)),
        ),
      );
      await database
          .into(database.cropSeasons)
          .insert(
            CropSeasonsCompanion.insert(
              id: 'assignment-2',
              ownerId: 'owner-1',
              sectorId: 'sector-1',
              agriculturalSeasonId: const Value('season-1'),
              cropId: 'trigo',
              startsOn: DateTime.utc(2026, 4),
              status: const Value('active'),
              updatedAt: DateTime.utc(2026, 4),
            ),
          );

      await expectLater(
        repository.correct(
          ownerId: 'owner-1',
          originalLaborId: originalId,
          occurredAt: DateTime.utc(2026, 5),
          details: const FertilizationDetails(
            product: 'Compost',
            amount: 25,
            unit: 'kg',
            applicationMethod: 'Banda',
          ).toEnvelope(),
        ),
        throwsA(
          predicate(
            (error) =>
                error is StateError &&
                error.message == 'labor_correction_assignment_changed',
          ),
        ),
      );
      expect(await database.select(database.labors).get(), hasLength(1));
    },
  );
}
