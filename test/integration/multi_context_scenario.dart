import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/features/crops/data/agricultural_season_repository.dart';
import 'package:agrocampo/features/crops/data/crop_repository.dart';
import 'package:agrocampo/features/crops/data/sector_crop_assignment_repository.dart';
import 'package:agrocampo/features/crops/domain/agricultural_season.dart';
import 'package:agrocampo/features/history/data/history_repository.dart';
import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/fertilization_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/file_backed_database.dart';

void main() {
  test(
    'three parcels and ten sectors each retain exact agricultural context',
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
      final expectedParcelBySector = <String, String>{};
      for (var parcelIndex = 0; parcelIndex < 3; parcelIndex++) {
        final parcelId = 'parcel-$parcelIndex';
        await ParcelRepository(database).save(
          ownerId: 'owner-1',
          id: parcelId,
          name: 'Campo $parcelIndex',
          isActive: parcelIndex == 0,
        );
        final seasonId = await AgriculturalSeasonRepository(database).save(
          ownerId: 'owner-1',
          parcelId: parcelId,
          name: 'Temporada $parcelIndex',
          startsOn: DateTime.utc(2026),
          endsOn: DateTime.utc(2027),
          status: AgriculturalSeasonStatus.active,
        );
        for (var sectorIndex = 0; sectorIndex < 10; sectorIndex++) {
          final offset = parcelIndex * .01 + sectorIndex * .002;
          final sectorId = await SectorRepository(database).save(
            ownerId: 'owner-1',
            parcelId: parcelId,
            number: sectorIndex + 1,
            name: 'Sector $parcelIndex-$sectorIndex',
            polygon: [
              GeoPoint(-38.74 + offset, -72.60),
              GeoPoint(-38.74 + offset, -72.59),
              GeoPoint(-38.739 + offset, -72.59),
            ],
          );
          expectedParcelBySector[sectorId] = parcelId;
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
            parcelId: parcelId,
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
      expect(await database.select(database.parcels).get(), hasLength(3));
      expect(await database.select(database.sectors).get(), hasLength(30));
      expect(await database.select(database.labors).get(), hasLength(30));
      for (final entry in expectedParcelBySector.entries) {
        final events = await HistoryRepository(database).list(
          HistoryFilter(
            ownerId: 'owner-1',
            parcelId: entry.value,
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
        expect(labor.parcelId, entry.value);
      }
    },
  );
}
