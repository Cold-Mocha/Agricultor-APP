import 'package:agrocampo_backend/src/modules/crop_cycles/domain/entities/agricultural_season.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/agricultural_season_repository.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/crop_repository.dart';
import 'package:agrocampo_backend/src/modules/crop_cycles/infrastructure/persistence/sector_crop_assignment_repository.dart';
import 'package:agrocampo_backend/src/modules/history/domain/entities/history_event.dart';
import 'package:agrocampo_backend/src/modules/history/infrastructure/persistence/history_repository.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/fertilization_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';
import 'package:agrocampo_backend/src/modules/labors/infrastructure/persistence/labor_repository.dart';
import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/file_backed_database.dart';

void main() {
  test(
    'thirty sectors with their own seasons retain exact agricultural context',
    () async {
      final fixture = await FileBackedDatabaseFixture.create();
      addTearDown(fixture.dispose);
      var database = fixture.open();
      addTearDown(() => database.close());
      await database
          .into(database.officialCrops)
          .insert(
            OfficialCropsCompanion.insert(
              id: 'trigo',
              commonName: 'Trigo',
              category: 'cereal',
              colorToken: 'cropWheat',
              iconAsset: 'wheat',
            ),
          );
      final crop = await CropRepository(database)
          .getById(ownerId: 'owner-1', cropId: 'trigo', isCustom: false);
      final expectedSeasonBySector = <String, String>{};
      for (var groupIndex = 0; groupIndex < 3; groupIndex++) {
        for (var sectorIndex = 0; sectorIndex < 10; sectorIndex++) {
          final offset = groupIndex * .01 + sectorIndex * .002;
          final number = groupIndex * 10 + sectorIndex + 1;
          final sectorId = await SectorRepository(database).save(
            ownerId: 'owner-1',
            number: number,
            name: 'Sector $number',
            polygon: [
              GeoPoint(-38.74 + offset, -72.60),
              GeoPoint(-38.74 + offset, -72.59),
              GeoPoint(-38.739 + offset, -72.59),
            ],
          );
          final seasonId = await AgriculturalSeasonRepository(database).save(
            ownerId: 'owner-1',
            sectorId: sectorId,
            name: 'Temporada $number',
            startsOn: DateTime.utc(2026),
            endsOn: DateTime.utc(2027),
            status: AgriculturalSeasonStatus.active,
          );
          expectedSeasonBySector[sectorId] = seasonId;
          final assignments = SectorCropAssignmentRepository(database);
          final assignmentId = await assignments.plan(
            ownerId: 'owner-1',
            sectorId: sectorId,
            agriculturalSeasonId: seasonId,
            crop: crop,
            effectiveFrom: DateTime.utc(2026),
          );
          await assignments.activate(
            ownerId: 'owner-1',
            assignmentId: assignmentId,
            effectiveAt: DateTime.utc(2026),
          );
          await LaborRepository(database).save(
            ownerId: 'owner-1',
            sectorId: sectorId,
            seasonId: seasonId,
            cropAssignmentId: assignmentId,
            type: LaborType.fertilization,
            occurredAt: DateTime.utc(2026, 2),
            details: const FertilizationDetails(
              product: 'Compost',
              amount: 10,
              unit: 'kg',
              applicationMethod: 'Banda',
            ).toEnvelope(),
          );
        }
      }
      await database.close();
      database = fixture.open();
      addTearDown(database.close);
      expect(
        await database.select(database.agriculturalSeasons).get(),
        hasLength(30),
      );
      expect(await database.select(database.sectors).get(), hasLength(30));
      expect(await database.select(database.labors).get(), hasLength(30));
      for (final entry in expectedSeasonBySector.entries) {
        final events = await HistoryRepository(database).list(
          HistoryFilter(
            ownerId: 'owner-1',
            sectorId: entry.key,
          ),
        );
        expect(events.map((event) => event.sectorId).toSet(), {entry.key});
        expect(
          events.where((event) => event.type == HistoryEventType.labor),
          hasLength(1),
        );
        expect(
          events.where((event) => event.cropLabel == 'Trigo'),
          hasLength(2),
        );
        final labor = await (database.select(
          database.labors,
        )..where((row) => row.sectorId.equals(entry.key))).getSingle();
        expect(labor.seasonId, entry.value);
      }
    },
  );
}
