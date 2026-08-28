import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/features/crops/data/crop_repository.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('territory and future rotation remain local and consistent', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final parcelId = await ParcelRepository(database)
        .save(ownerId: 'owner-1', name: 'Campo demo', isActive: true);
    final sectorId = await SectorRepository(database).save(
      ownerId: 'owner-1',
      parcelId: parcelId,
      number: 1,
      name: 'Sector norte',
      polygon: const [
        GeoPoint(-38.74, -72.60),
        GeoPoint(-38.74, -72.59),
        GeoPoint(-38.73, -72.59),
      ],
    );
    await CropRepository(database).planRotation(
      ownerId: 'owner-1',
      sectorId: sectorId,
      cropId: 'trigo',
      startsOn: DateTime.utc(2027),
    );

    expect(
      (await database.select(database.parcels).getSingle()).isActive,
      isTrue,
    );
    expect(
      (await database.select(database.cropSeasons).getSingle()).status,
      'planned',
    );
  });
}
