import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/history/data/history_repository.dart';
import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_database.dart';
import '../helpers/territory_fixture.dart';

void main() {
  test(
    'common timeline and outbox queries remain well below two seconds',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      await seedAgriculturalContextFixture(database);
      final now = DateTime.utc(2026, 8, 30);
      final contexts = <(String, String)>[('parcel-1', 'sector-1')];
      await database.batch((batch) {
        for (var parcelIndex = 1; parcelIndex <= 20; parcelIndex++) {
          final parcelId = 'parcel-$parcelIndex';
          if (parcelIndex > 1) {
            batch.insert(
              database.parcels,
              ParcelsCompanion.insert(
                id: parcelId,
                ownerId: 'owner-1',
                name: 'Campo $parcelIndex',
                updatedAt: now,
              ),
            );
          }
          for (var sectorIndex = 1; sectorIndex <= 10; sectorIndex++) {
            final sectorId = 'sector-$parcelIndex-$sectorIndex';
            if (parcelIndex == 1 && sectorIndex == 1) continue;
            batch.insert(
              database.sectors,
              SectorsCompanion.insert(
                id: sectorId,
                ownerId: 'owner-1',
                parcelId: parcelId,
                number: sectorIndex,
                name: 'Sector $parcelIndex-$sectorIndex',
                polygonJson: '[]',
                areaSquareMeters: 100,
                updatedAt: now,
              ),
            );
            contexts.add((parcelId, sectorId));
          }
        }
      });
      expect(contexts, hasLength(200));
      await database.batch((batch) {
        for (var index = 0; index < 10000; index++) {
          final context = contexts[index % contexts.length];
          final isTargetSector = context.$2 == 'sector-1';
          batch.insert(
            database.labors,
            LaborsCompanion.insert(
              id: 'labor-$index',
              ownerId: 'owner-1',
              parcelId: context.$1,
              sectorId: context.$2,
              seasonId: isTargetSector
                  ? const Value('season-1')
                  : const Value.absent(),
              cropAssignmentId: isTargetSector
                  ? const Value('assignment-1')
                  : const Value.absent(),
              type: 'fertilization',
              occurredAt: now.subtract(Duration(minutes: index)),
              updatedAt: now,
            ),
          );
          batch.insert(
            database.syncOutbox,
            SyncOutboxCompanion.insert(
              operationId: 'operation-$index',
              ownerId: 'owner-1',
              aggregateType: 'labor',
              aggregateId: 'labor-$index',
              mutationKind: 'create',
              payloadJson: '{"id":"labor-$index"}',
              requestHash: Value('hash-$index'),
              createdAt: now,
            ),
          );
        }
      });
      expect(await database.select(database.parcels).get(), hasLength(20));
      expect(await database.select(database.sectors).get(), hasLength(200));
      expect(await database.select(database.labors).get(), hasLength(10000));
      final durations = <Duration>[];
      for (var run = 0; run < 20; run++) {
        final watch = Stopwatch()..start();
        final events = await HistoryRepository(database).list(
          const HistoryFilter(
            ownerId: 'owner-1',
            parcelId: 'parcel-1',
            sectorId: 'sector-1',
            limit: 50,
          ),
        );
        watch.stop();
        expect(events, hasLength(50));
        durations.add(watch.elapsed);
      }
      durations.sort();
      final p95 = durations[(durations.length * .95).ceil() - 1];
      expect(p95, lessThan(const Duration(seconds: 2)));

      final outboxWatch = Stopwatch()..start();
      final eligible = await database.syncOutboxDao.eligibleBatch(
        'owner-1',
        limit: 100,
      );
      outboxWatch.stop();
      expect(eligible, hasLength(100));
      expect(outboxWatch.elapsed, lessThan(const Duration(seconds: 2)));
      final plan = await database
          .customSelect(
            'EXPLAIN QUERY PLAN SELECT * FROM labors WHERE owner_id = ? AND sector_id = ? '
            'ORDER BY occurred_at DESC LIMIT 100',
            variables: [const Variable('owner-1'), const Variable('sector-1')],
          )
          .get();
      expect(
        plan.map((row) => row.data.values.join(' ')).join(' '),
        contains('idx_labors_history'),
      );
    },
  );
}
