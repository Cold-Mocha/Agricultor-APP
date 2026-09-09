import 'package:agrocampo_backend/src/composition/sync_codec_composition.dart';
import 'package:agrocampo_backend/src/modules/territory/infrastructure/persistence/parcel_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/sync/protocol/sync_contract.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_coordinator.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_gateway.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offline parcel survives restart and synchronizes once', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await ParcelRepository(database)
        .save(ownerId: 'owner-1', name: 'Parcela offline');

    final gateway = _IntegrationGateway();
    await SyncCoordinator(
      database,
      gateway,
      registry: createAgroCampoSyncRegistry(),
    ).synchronize('owner-1');

    expect(gateway.operations, hasLength(1));
    expect(
      (await database.select(database.parcels).getSingle()).name,
      'Parcela offline',
    );
  });
}

final class _IntegrationGateway implements SyncGateway {
  final operations = <String>{};

  @override
  Future<PullResult> pull({
    required String ownerId,
    required int afterCursor,
  }) async => PullResult(nextCursor: afterCursor);

  @override
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  }) async {
    this.operations.addAll(
      operations.map((operation) => operation.operationId),
    );
    return PushResult(
      operations: operations
          .map(
            (operation) => PushOperationResult(
              operationId: operation.operationId,
              status: PushOperationStatus.applied,
            ),
          )
          .toList(growable: false),
    );
  }
}
