import 'package:agrocampo/features/irrigation/data/irrigation_repository.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_record.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  test(
    'basic irrigation keeps type, soil classification and computed volume',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await seedTerritoryFixture(database);
      await IrrigationRepository(database).saveBasic(
        ownerId: 'owner-1',
        sectorId: 'sector-1',
        input: const BasicIrrigationInput(
          type: IrrigationType.drip,
          soilType: SoilType.loamy,
          durationMinutes: 30,
          flowLitersPerHour: 120,
        ),
      );
      final row = await database.select(database.irrigationRecords).getSingle();
      expect(row.soilTypeCode, 'loamy');
      expect(row.estimatedLiters, 60);
    },
  );
}
