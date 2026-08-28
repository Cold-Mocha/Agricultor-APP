import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/core/sync/sync_coordinator.dart';
import 'package:agrocampo/core/sync/sync_gateway.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase database;
  late _AckLossGateway gateway;

  setUp(() {
    database = createInMemoryDatabase();
    gateway = _AckLossGateway();
  });
  tearDown(() => database.close());

  test(
    'lost ACK retries 100 operations without duplicate business rows',
    () async {
      final repository = ParcelRepository(database);
      for (var index = 0; index < 100; index++) {
        await repository.save(ownerId: 'owner-1', name: 'Parcela $index');
      }
      final coordinator = SyncCoordinator(database, gateway);

      await expectLater(
        coordinator.synchronize('owner-1'),
        throwsA(isA<StateError>()),
      );
      expect(gateway.serverOperationIds, hasLength(100));
      expect(
        (await database.select(database.syncOutbox).get()).every(
          (row) => row.state == 'pending',
        ),
        isTrue,
      );

      final retry = await coordinator.synchronize('owner-1');

      expect(retry.pushed, 100);
      expect(gateway.serverOperationIds, hasLength(100));
      expect(
        (await database.select(database.syncOutbox).get()).every(
          (row) => row.state == 'done',
        ),
        isTrue,
      );
      expect(
        await database.syncCursorDao.read('owner-1', SyncCoordinator.stream),
        7,
      );
    },
  );

  test('remote conflict is durable until an explicit resolution', () async {
    gateway.loseFirstAck = false;
    gateway.conflict = const RemoteConflict(
      id: 'conflict-1',
      aggregateType: 'parcel',
      aggregateId: 'parcel-1',
      localJson: '{"name":"Local"}',
      remoteJson: '{"name":"Remota"}',
    );

    final result = await SyncCoordinator(
      database,
      gateway,
    ).synchronize('owner-1');

    expect(result.conflicts, 1);
    expect(await database.select(database.syncConflicts).get(), hasLength(1));
  });
}

final class _AckLossGateway implements SyncGateway {
  final serverOperationIds = <String>{};
  bool loseFirstAck = true;
  bool _didLoseAck = false;
  RemoteConflict? conflict;

  @override
  Future<PullResult> pull({
    required String ownerId,
    required int afterCursor,
  }) async => PullResult(nextCursor: 7, conflicts: [?conflict]);

  @override
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  }) async {
    serverOperationIds.addAll(
      operations.map((operation) => operation.operationId),
    );
    if (loseFirstAck && !_didLoseAck) {
      _didLoseAck = true;
      throw StateError('ACK lost after commit');
    }
    return PushResult(
      acknowledgedOperationIds: operations
          .map((operation) => operation.operationId)
          .toSet(),
    );
  }
}
