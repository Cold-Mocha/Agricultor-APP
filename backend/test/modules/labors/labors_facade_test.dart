import 'dart:convert';

import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
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

  group('editing a past labor', () {
    late AppDatabase database;
    late ProviderContainer container;

    setUp(() async {
      database = createInMemoryDatabase();
      container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
      );
      await seedAgriculturalContextFixture(database);
    });

    tearDown(() {
      container.dispose();
      return database.close();
    });

    Future<String> saveFertilization() async {
      await container
          .read(laborsFacadeProvider)
          .saveOutcome(
            ownerId: 'owner-1',
            input: LaborFormInput(
              sectorId: 'sector-1',
              type: LaborType.fertilization,
              occurredAt: DateTime.utc(2026),
              primary: 'Compost',
              secondary: 'Manual',
              amount: '5',
              unit: 'kg',
              extra: '',
              customName: '',
              notes: 'Aplicado en la mañana',
            ),
          );
      return (await database.select(database.labors).getSingle()).id;
    }

    test('loadForEdit reverse-maps details back into form fields', () async {
      final laborId = await saveFertilization();

      final draft = await container
          .read(laborsFacadeProvider)
          .loadForEdit(ownerId: 'owner-1', laborId: laborId);

      expect(draft, isNotNull);
      expect(draft!.type, LaborType.fertilization);
      expect(draft.sectorId, 'sector-1');
      expect(draft.primary, 'Compost');
      expect(draft.secondary, 'Manual');
      expect(draft.amount, '5');
      expect(draft.unit, 'kg');
      expect(draft.notes, 'Aplicado en la mañana');
    });

    test('correctOutcome supersedes the original and keeps it visible as corrected', () async {
      final originalId = await saveFertilization();

      final result = await container
          .read(laborsFacadeProvider)
          .correctOutcome(
            ownerId: 'owner-1',
            originalLaborId: originalId,
            input: LaborFormInput(
              sectorId: 'sector-1',
              type: LaborType.fertilization,
              occurredAt: DateTime.utc(2026),
              primary: 'Compost',
              secondary: 'Manual',
              amount: '8',
              unit: 'kg',
              extra: '',
              customName: '',
              notes: 'Corregido: era más cantidad',
            ),
          );

      expect(result, isA<SavedLocal<LaborFormInput>>());
      final rows = await database.select(database.labors).get();
      expect(rows, hasLength(2));
      final original = rows.singleWhere((row) => row.id == originalId);
      expect(original.status, 'corrected');
      final replacement = rows.singleWhere((row) => row.id != originalId);
      expect(replacement.status, 'recorded');
      expect(replacement.supersedesLaborId, originalId);
      expect(replacement.notes, 'Corregido: era más cantidad');

      // The corrected original no longer offers editing; its replacement does.
      final facade = container.read(laborsFacadeProvider);
      expect(
        await facade.loadForEdit(ownerId: 'owner-1', laborId: originalId),
        isNull,
      );
      expect(
        await facade.loadForEdit(ownerId: 'owner-1', laborId: replacement.id),
        isNotNull,
      );
    });

    test('loadForEdit returns null for types without a generic form', () async {
      await database
          .into(database.labors)
          .insert(
            LaborsCompanion.insert(
              id: 'labor-soil',
              ownerId: 'owner-1',
              sectorId: 'sector-1',
              type: 'soil',
              occurredAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );

      final draft = await container
          .read(laborsFacadeProvider)
          .loadForEdit(ownerId: 'owner-1', laborId: 'labor-soil');

      expect(draft, isNull);
    });

    test('loadForEdit returns null for an unknown labor', () async {
      final draft = await container
          .read(laborsFacadeProvider)
          .loadForEdit(ownerId: 'owner-1', laborId: 'missing');

      expect(draft, isNull);
    });
  });
}
