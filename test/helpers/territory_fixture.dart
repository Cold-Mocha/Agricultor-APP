import 'package:agrocampo/core/database/app_database.dart';
import 'package:drift/drift.dart';

Future<void> seedTerritoryFixture(AppDatabase database) async {
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
  await database
      .into(database.sectors)
      .insert(
        SectorsCompanion.insert(
          id: 'sector-1',
          ownerId: 'owner-1',
          parcelId: 'parcel-1',
          number: 1,
          name: 'Sector 1',
          polygonJson: '[]',
          areaSquareMeters: 100,
          updatedAt: DateTime.utc(2026),
        ),
      );
}

Future<void> seedAgriculturalContextFixture(
  AppDatabase database, {
  DateTime? startsOn,
  DateTime? endsOn,
  String status = 'active',
}) async {
  await seedTerritoryFixture(database);
  final start = startsOn ?? DateTime.utc(2025);
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
  await database
      .into(database.agriculturalSeasons)
      .insert(
        AgriculturalSeasonsCompanion.insert(
          id: 'season-1',
          ownerId: 'owner-1',
          parcelId: 'parcel-1',
          name: 'Temporada 2025/26',
          startsOn: start,
          endsOn: Value(endsOn),
          status: Value(status),
          updatedAt: DateTime.utc(2026),
        ),
      );
  await database
      .into(database.cropSeasons)
      .insert(
        CropSeasonsCompanion.insert(
          id: 'assignment-1',
          ownerId: 'owner-1',
          sectorId: 'sector-1',
          agriculturalSeasonId: const Value('season-1'),
          cropId: 'trigo',
          startsOn: start,
          endsOn: Value(endsOn),
          status: Value(status == 'closed' ? 'ended' : 'active'),
          updatedAt: DateTime.utc(2026),
        ),
      );
}
