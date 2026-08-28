import 'package:agrocampo/core/geometry/geo_point.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/features/sectors/data/sector_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('sector numbers are unique per parcel', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final parcelId = await ParcelRepository(database)
        .save(ownerId: 'owner-1', name: 'Campo');
    const polygon = [
      GeoPoint(-38.74, -72.60),
      GeoPoint(-38.74, -72.59),
      GeoPoint(-38.73, -72.59),
    ];
    final repository = SectorRepository(database);
    await repository.save(
      ownerId: 'owner-1',
      parcelId: parcelId,
      number: 1,
      name: 'Sector 1',
      polygon: polygon,
    );

    await expectLater(
      repository.save(
        ownerId: 'owner-1',
        parcelId: parcelId,
        number: 1,
        name: 'Duplicado',
        polygon: polygon,
      ),
      throwsA(anything),
    );
  });
}
