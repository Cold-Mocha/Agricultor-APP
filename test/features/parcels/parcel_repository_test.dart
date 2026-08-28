import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test('only one parcel remains active and every save queues outbox', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final repository = ParcelRepository(database);
    await repository.save(ownerId: 'owner-1', name: 'Norte', isActive: true);
    await repository.save(ownerId: 'owner-1', name: 'Sur', isActive: true);

    final parcels = await database.select(database.parcels).get();
    expect(parcels.where((parcel) => parcel.isActive), hasLength(1));
    expect(await database.select(database.syncOutbox).get(), hasLength(2));
  });
}
