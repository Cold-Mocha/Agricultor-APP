import 'package:agrocampo/core/database/app_database.dart';

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
