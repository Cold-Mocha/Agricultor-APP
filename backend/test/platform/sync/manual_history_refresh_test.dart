import 'dart:convert';

import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:agrocampo_backend/src/modules/history/infrastructure/persistence/history_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/sync_contract.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_coordinator.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_gateway.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/sync_test_coordinator.dart';

final class _Gateway implements SyncGateway, SectorExistenceGateway {
  final present = <String>{};
  final changes = <RemoteChange>[];
  final cursors = <int>[];
  List<String> checked = [];
  Object? failure;
  Future<void> Function()? duringInventory;
  int pushes = 0;
  @override
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  }) async {
    pushes++;
    throw StateError('A read-only refresh must not push');
  }

  @override
  Future<PullResult> pull({
    required String ownerId,
    required int afterCursor,
  }) async {
    cursors.add(afterCursor);
    final page = changes
        .where((row) => row.sequence > afterCursor)
        .take(200)
        .toList();
    return PullResult(
      nextCursor: page.isEmpty ? afterCursor : page.last.sequence,
      changes: page,
    );
  }

  @override
  Future<Set<String>> existingSectorIds({
    required String ownerId,
    required List<String> candidateIds,
  }) async {
    checked = candidateIds;
    if (failure != null) throw failure!;
    await duringInventory?.call();
    return present.intersection(candidateIds.toSet());
  }
}

Future<void> _sector(
  AppDatabase db,
  String id, {
  String owner = 'owner',
  bool retired = true,
}) async {
  await db
      .into(db.sectors)
      .insert(
        SectorsCompanion.insert(
          id: id,
          ownerId: owner,
          number: id == 'real' ? 2 : 1,
          name: id,
          polygonJson: '[]',
          areaSquareMeters: 43,
          updatedAt: DateTime.utc(2026),
          syncState: const Value('synced'),
          deletedAt: retired ? Value(DateTime.utc(2026)) : const Value.absent(),
        ),
      );
}

RemoteChange _change(int number, {String? id, String? name}) => RemoteChange(
  sequence: number,
  aggregateType: 'sector',
  aggregateId: id ?? 'remote-$number',
  kind: 'create',
  remoteVersion: 2,
  payloadJson: jsonEncode({
    'id': id ?? 'remote-$number',
    'name': name ?? 'Sector $number',
    'number': number,
    'kind': 'crop',
    'polygon': [
      {'lat': -38.74, 'lng': -72.60},
      {'lat': -38.74, 'lng': -72.59},
      {'lat': -38.73, 'lng': -72.59},
    ],
    'updated_at': '2026-10-16T12:00:00Z',
  }),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'missing retired cache leaves history, preserves rows and can be restored',
    () async {
      final db = createInMemoryDatabase();
      addTearDown(db.close);
      await _sector(db, 'qa');
      await _sector(db, 'real');
      await _sector(db, 'active', retired: false);
      await _sector(db, 'foreign', owner: 'other');
      await db
          .into(db.labors)
          .insert(
            LaborsCompanion.insert(
              id: 'qa-labor',
              ownerId: 'owner',
              sectorId: 'qa',
              type: 'other',
              occurredAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );
      await db
          .into(db.labors)
          .insert(
            LaborsCompanion.insert(
              id: 'real-labor',
              ownerId: 'owner',
              sectorId: 'real',
              type: 'pruning',
              occurredAt: DateTime.utc(2025),
              updatedAt: DateTime.utc(2025),
            ),
          );
      final gateway = _Gateway()..present.add('real');
      final coordinator = createTestSyncCoordinator(db, gateway);
      final result = await coordinator.refresh('owner');
      expect(result.unavailableSectorIds, ['qa']);
      expect(gateway.checked.toSet(), {'qa', 'real'});
      expect(gateway.pushes, 0);
      final repo = HistoryRepository(db);
      expect(
        (await repo.watchSectors('owner').first).map((s) => s.id).toSet(),
        {'real', 'active'},
      );
      expect(
        (await repo.list(const HistoryFilter(ownerId: 'owner', limit: 1)))
            .single
            .id,
        'real-labor',
      );
      expect((await repo.listAll('owner')).single.id, 'real-labor');
      expect(
        await db.select(db.labors).get(),
        hasLength(2),
        reason: 'No cached history is destroyed',
      );
      expect(await db.select(db.sectors).get(), hasLength(4));
      gateway.present.add('qa');
      await coordinator.refresh('owner');
      expect(
        await repo.list(const HistoryFilter(ownerId: 'owner')),
        hasLength(2),
      );
    },
  );

  test('refresh preserves pending edits and never pushes them', () async {
    final db = createInMemoryDatabase();
    addTearDown(db.close);
    await _sector(db, 'qa');
    await db
        .into(db.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            operationId: 'pending',
            ownerId: 'owner',
            aggregateType: 'sector',
            aggregateId: 'qa',
            mutationKind: 'update',
            payloadJson: '{}',
            createdAt: DateTime.utc(2026),
          ),
        );
    final gateway = _Gateway()
      ..changes.add(_change(1, id: 'qa', name: 'Remote overwrite'));
    final result = await createTestSyncCoordinator(
      db,
      gateway,
    ).refresh('owner');
    expect(result.localChangesProtected, isTrue);
    expect(result.unavailableSectorIds, isEmpty);
    final local = await db.select(db.sectors).getSingle();
    expect(local.name, 'qa');
    expect(local.syncState, 'synced');
    expect((await db.select(db.syncOutbox).getSingle()).state, 'pending');
    expect(gateway.pushes, 0);
  });

  test('inventory network failure cannot hide cached sectors', () async {
    final db = createInMemoryDatabase();
    addTearDown(db.close);
    await _sector(db, 'qa');
    final gateway = _Gateway()..failure = StateError('offline');
    await expectLater(
      createTestSyncCoordinator(db, gateway).refresh('owner'),
      throwsStateError,
    );
    expect((await db.select(db.sectors).getSingle()).syncState, 'synced');
  });

  test('local change made during the remote check wins', () async {
    final db = createInMemoryDatabase();
    addTearDown(db.close);
    await _sector(db, 'qa');
    final gateway = _Gateway()
      ..duringInventory = () async {
        await (db.update(db.sectors)..where((r) => r.id.equals('qa'))).write(
          const SectorsCompanion(
            version: Value(2),
            name: Value('New local name'),
          ),
        );
      };
    expect(
      (await createTestSyncCoordinator(db, gateway).refresh('owner'))
          .unavailableSectorIds,
      isEmpty,
    );
    expect((await db.select(db.sectors).getSingle()).name, 'New local name');
  });

  for (final work in ['draft', 'photo', 'conflict']) {
    test('$work protects local cache from absence reconciliation', () async {
      final db = createInMemoryDatabase();
      addTearDown(db.close);
      await _sector(db, 'qa');
      if (work == 'draft') {
        await db
            .into(db.formDrafts)
            .insert(
              FormDraftsCompanion.insert(
                ownerId: 'owner',
                draftKey: 'draft',
                payloadJson: '{}',
                updatedAt: DateTime.utc(2026),
              ),
            );
      } else if (work == 'photo') {
        await db
            .into(db.photoAttachments)
            .insert(
              PhotoAttachmentsCompanion.insert(
                id: 'photo',
                ownerId: 'owner',
                aggregateType: 'sector',
                aggregateId: 'qa',
                localPath: 'private.png',
                contentHash: 'hash',
                mimeType: 'image/png',
                capturedAt: DateTime.utc(2026),
              ),
            );
      } else {
        await db
            .into(db.syncConflicts)
            .insert(
              SyncConflictsCompanion.insert(
                conflictId: 'conflict',
                ownerId: 'owner',
                aggregateType: 'sector',
                aggregateId: 'qa',
                localJson: '{}',
                remoteJson: '{}',
                detectedAt: DateTime.utc(2026),
              ),
            );
      }
      final result = await createTestSyncCoordinator(
        db,
        _Gateway(),
      ).refresh('owner');
      expect(result.localChangesProtected, isTrue);
      expect((await db.select(db.sectors).getSingle()).syncState, 'synced');
    });
  }

  test(
    'refresh drains every page rather than stopping at 200 changes',
    () async {
      final db = createInMemoryDatabase();
      addTearDown(db.close);
      final gateway = _Gateway()
        ..changes.addAll(List.generate(201, (i) => _change(i + 1)));
      final result = await createTestSyncCoordinator(
        db,
        gateway,
      ).refresh('owner');
      expect(result.pulled, 201);
      expect(gateway.cursors, [0, 200]);
      expect(await db.select(db.sectors).get(), hasLength(201));
      expect(await db.syncCursorDao.read('owner', SyncCoordinator.stream), 201);
    },
  );
}
