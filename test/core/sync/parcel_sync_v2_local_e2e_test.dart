import 'dart:io';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/sync/protocol/supabase_sync_gateway.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/core/sync/sync_coordinator.dart';
import 'package:agrocampo/core/sync/sync_gateway.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test(
    'real Supabase lost ACK is idempotent and pulls into a second DB',
    () async {
      const url = String.fromEnvironment('SUPABASE_URL');
      const key = String.fromEnvironment('SUPABASE_ANON_KEY');
      if (url.isEmpty || key.isEmpty) return;
      final client = SupabaseClient(
        url,
        key,
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );
      addTearDown(client.dispose);
      final suffix = DateTime.now().microsecondsSinceEpoch;
      final auth = await client.auth.signUp(
        email: 'parcel-local-$suffix@agrocampo.local',
        password: 'AgroCampo-$suffix!',
      );
      final ownerId = auth.user!.id;
      expect(auth.session, isNotNull);

      final directoryA = await Directory.systemTemp.createTemp(
        'parcel-real-a-',
      );
      final fileA = File(
        '${directoryA.path}${Platform.pathSeparator}db.sqlite',
      );
      var databaseA = AppDatabase.forTesting(NativeDatabase(fileA));
      addTearDown(() async {
        await databaseA.close();
        await directoryA.delete(recursive: true);
      });
      final parcelId = await ParcelRepository(databaseA)
          .save(ownerId: ownerId, name: 'Parcela real', isActive: true);
      await databaseA.close();
      databaseA = AppDatabase.forTesting(NativeDatabase(fileA));

      final real = SupabaseSyncGateway(client);
      final lossy = _LossyGateway(real);
      await expectLater(
        SyncCoordinator(databaseA, lossy).synchronize(ownerId),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'simulated_lost_ack',
          ),
        ),
      );
      expect(
        (await databaseA.select(databaseA.syncOutbox).getSingle()).state,
        'pending',
      );
      expect(
        await client.from('parcels').select('id').eq('id', parcelId),
        hasLength(1),
      );

      await SyncCoordinator(databaseA, lossy).synchronize(ownerId);
      expect(
        (await databaseA.select(databaseA.syncOutbox).getSingle()).state,
        'done',
      );
      expect(
        (await databaseA.select(databaseA.parcels).getSingle()).syncState,
        'synced',
      );
      expect(
        await client.from('parcels').select('id').eq('id', parcelId),
        hasLength(1),
      );

      final directoryB = await Directory.systemTemp.createTemp(
        'parcel-real-b-',
      );
      final databaseB = AppDatabase.forTesting(
        NativeDatabase(
          File('${directoryB.path}${Platform.pathSeparator}db.sqlite'),
        ),
      );
      addTearDown(() async {
        await databaseB.close();
        await directoryB.delete(recursive: true);
      });
      await SyncCoordinator(databaseB, real).synchronize(ownerId);
      final downloaded = await databaseB.select(databaseB.parcels).getSingle();
      expect(downloaded.id, parcelId);
      expect(downloaded.ownerId, ownerId);
    },
  );
}

final class _LossyGateway implements SyncGateway {
  _LossyGateway(this.delegate);
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
    final result = await delegate.push(
      ownerId: ownerId,
      operations: operations,
    );
    if (result.operations.any((item) => !item.isAcknowledged)) {
      throw StateError(
        'remote_rejected:${result.operations.map((item) => item.errorCode).join(',')}',
      );
    }
    if (!lost) {
      lost = true;
      throw StateError('simulated_lost_ack');
    }
    return result;
  }
}
