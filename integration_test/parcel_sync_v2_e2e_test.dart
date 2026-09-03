import 'dart:io';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/supabase_sync_gateway.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/core/sync/sync_coordinator.dart';
import 'package:agrocampo/core/sync/sync_gateway.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('real parcel cut survives lost ACK and pulls into second DB', (
    tester,
  ) async {
    const url = String.fromEnvironment('SUPABASE_URL');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (url.isEmpty || anonKey.isEmpty) {
      fail('SUPABASE_URL and SUPABASE_ANON_KEY are required');
    }
    final client = SupabaseClient(
      url,
      anonKey,
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
    addTearDown(client.dispose);
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final auth = await client.auth.signUp(
      email: 'parcel-e2e-$suffix@agrocampo.local',
      password: 'AgroCampo-$suffix!',
    );
    final ownerId = auth.user!.id;
    expect(
      auth.session,
      isNotNull,
      reason: 'local signup must establish session',
    );

    final firstDirectory = await Directory.systemTemp.createTemp(
      'parcel-v2-a-',
    );
    final firstFile = File(
      '${firstDirectory.path}${Platform.pathSeparator}db.sqlite',
    );
    var firstDb = AppDatabase.forTesting(NativeDatabase(firstFile));
    addTearDown(() async {
      await firstDb.close();
      await firstDirectory.delete(recursive: true);
    });
    final parcelId = await ParcelRepository(firstDb)
        .save(ownerId: ownerId, name: 'Parcela ACK perdido', isActive: true);
    await firstDb.close();
    firstDb = AppDatabase.forTesting(NativeDatabase(firstFile));

    final realGateway = SupabaseSyncGateway(client);
    final lostAckGateway = _LoseFirstAckGateway(realGateway);
    await expectLater(
      SyncCoordinator(firstDb, lostAckGateway).synchronize(ownerId),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'simulated_ack_loss_after_remote_commit',
        ),
      ),
    );
    expect(
      await client.from('parcels').select('id').eq('id', parcelId),
      hasLength(1),
    );
    expect(
      (await firstDb.select(firstDb.syncOutbox).getSingle()).state,
      'pending',
    );

    await SyncCoordinator(firstDb, lostAckGateway).synchronize(ownerId);
    expect(
      await client.from('parcels').select('id').eq('id', parcelId),
      hasLength(1),
    );
    expect(
      (await firstDb.select(firstDb.syncOutbox).getSingle()).state,
      'done',
    );
    expect(
      (await firstDb.select(firstDb.parcels).getSingle()).syncState,
      'synced',
    );

    final secondDirectory = await Directory.systemTemp.createTemp(
      'parcel-v2-b-',
    );
    final secondFile = File(
      '${secondDirectory.path}${Platform.pathSeparator}db.sqlite',
    );
    final secondDb = AppDatabase.forTesting(NativeDatabase(secondFile));
    addTearDown(() async {
      await secondDb.close();
      await secondDirectory.delete(recursive: true);
    });
    await SyncCoordinator(secondDb, realGateway).synchronize(ownerId);
    final downloaded = await secondDb.select(secondDb.parcels).getSingle();
    expect(downloaded.id, parcelId);
    expect(downloaded.name, 'Parcela ACK perdido');
    expect(downloaded.ownerId, ownerId);
  });
}

final class _LoseFirstAckGateway implements SyncGateway {
  _LoseFirstAckGateway(this.delegate);

  final SyncGateway delegate;
  bool lost = false;

  @override
  Future<PullResult> pull({
    required String ownerId,
    required int afterCursor,
  }) => delegate.pull(ownerId: ownerId, afterCursor: afterCursor);

  @override
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  }) async {
    final response = await delegate.push(
      ownerId: ownerId,
      operations: operations,
    );
    if (response.operations.any((item) => !item.isAcknowledged)) {
      throw StateError(
        'remote_rejected:${response.operations.map((item) => item.errorCode).join(',')}',
      );
    }
    if (!lost) {
      lost = true;
      throw StateError('simulated_ack_loss_after_remote_commit');
    }
    return response;
  }
}
