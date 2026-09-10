import 'package:agrocampo_backend/src/modules/territory/domain/value_objects/geo_point.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/parcel_repository.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/sector_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_database.dart';

void main() {
  const triangle = [
    GeoPoint(-38.74, -72.60),
    GeoPoint(-38.74, -72.59),
    GeoPoint(-38.73, -72.59),
  ];

  test('confirmed sector contract requires a stable category and version', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final parcelId = await ParcelRepository(database).save(
      ownerId: 'owner-1',
      name: 'Campo',
    );
    final repository = SectorRepository(database);
    final id = await repository.saveConfirmed(
      ownerId: 'owner-1',
      parcelId: parcelId,
      number: 1,
      name: 'Apiario',
      kind: 'apiary',
      polygon: triangle,
    );
    expect((await database.select(database.sectors).getSingle()).kind, 'apiary');
    await expectLater(
      repository.saveConfirmed(
        ownerId: 'owner-1',
        parcelId: parcelId,
        number: 1,
        name: 'Apiario',
        kind: 'crop',
        id: id,
        expectedVersion: 1,
        polygon: triangle,
      ),
      throwsStateError,
    );
    await expectLater(
      repository.saveConfirmed(
        ownerId: 'owner-1',
        parcelId: parcelId,
        number: 1,
        name: 'Apiario',
        kind: 'apiary',
        id: id,
        expectedVersion: 0,
        polygon: triangle,
      ),
      throwsStateError,
    );
  });
}
