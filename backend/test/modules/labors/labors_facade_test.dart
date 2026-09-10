import 'dart:convert';

import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'invalid numeric input returns field error and keeps the command',
    () async {
      final database = createInMemoryDatabase();
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      addTearDown(database.close);
      addTearDown(container.dispose);
      await seedAgriculturalContextFixture(database);

      final input = LaborFormInput(
        sectorId: 'sector-1',
        type: LaborType.fertilization,
        occurredAt: DateTime.utc(2026),
        primary: 'Compost',
        secondary: 'Manual',
        amount: 'no-es-numero',
        unit: 'kg',
        extra: '',
        customName: '',
        notes: 'Conservar',
      );
      final result = await container
          .read(laborsFacadeProvider)
          .saveOutcome(ownerId: 'owner-1', input: input);

      expect(result, isA<ValidationFailed<LaborFormInput>>());
      final failure = result as ValidationFailed<LaborFormInput>;
      expect(failure.preservedInput, same(input));
      expect(failure.fieldErrors.single.fieldId, 'amount');
      final draft = await database.formDraftDao.read('owner-1', 'labor');
      expect(jsonDecode(draft!)['amount'], 'no-es-numero');
    },
  );

  test('context mismatch is rejected without creating a labor row', () async {
    final database = createInMemoryDatabase();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(database.close);
    addTearDown(container.dispose);

    final input = LaborFormInput(
      sectorId: 'missing-sector',
      type: LaborType.other,
      occurredAt: DateTime.utc(2026),
      primary: 'Anotación',
      secondary: '',
      amount: '',
      unit: '',
      extra: '',
      customName: 'Otra',
      notes: 'Sin contexto',
    );
    final result = await container
        .read(laborsFacadeProvider)
        .saveOutcome(ownerId: 'owner-1', input: input);

    expect(result, isA<DomainRejected<LaborFormInput>>());
    expect(
      (result as DomainRejected<LaborFormInput>).preservedInput,
      same(input),
    );
    expect(await database.select(database.labors).get(), isEmpty);
  });

  test('storage failure preserves draft and returns typed failure', () async {
    final database = createInMemoryDatabase();
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(database.close);
    addTearDown(container.dispose);
    await seedAgriculturalContextFixture(database);
    await database.customStatement('DROP TABLE labors');

    final input = LaborFormInput(
      sectorId: 'sector-1',
      type: LaborType.other,
      occurredAt: DateTime.utc(2026),
      primary: 'Nota de almacenamiento',
      secondary: '',
      amount: '',
      unit: '',
      extra: '',
      customName: 'Otra',
      notes: 'Conservar para reintento',
    );
    final result = await container
        .read(laborsFacadeProvider)
        .saveOutcome(ownerId: 'owner-1', input: input);

    expect(result, isA<StorageFailed<LaborFormInput>>());
    expect(
      (result as StorageFailed<LaborFormInput>).preservedInput,
      same(input),
    );
    final draft = await database.formDraftDao.read('owner-1', 'labor');
    expect(jsonDecode(draft!)['notes'], 'Conservar para reintento');
  });
}
