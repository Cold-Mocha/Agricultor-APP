import 'package:agrocampo/features/crops/data/crop_repository.dart';
import 'package:agrocampo/features/crops/data/crop_seed_loader.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('approved official crop pictograms are available offline', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);

    await CropSeedLoader(database).seedIfEmpty();
    final crops = await CropRepository(database).watchCatalog('owner-1').first;

    expect(
      crops.map((crop) => crop.label),
      containsAll([
        'Frambuesa',
        'Arándano',
        'Papa',
        'Sandía',
        'Melón',
        'Maíz',
        'Physalis',
        'Frutilla',
        'Apicultura',
      ]),
    );
    expect(
      crops.singleWhere((crop) => crop.id == 'frambuesa').iconAsset,
      'assets/icons/raspberry.svg',
    );
    expect(
      crops.singleWhere((crop) => crop.id == 'apicultura').iconAsset,
      'assets/icons/crops/apiary.svg',
    );
  });
}
