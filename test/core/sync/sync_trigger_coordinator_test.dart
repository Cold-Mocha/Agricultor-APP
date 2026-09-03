import 'dart:async';

import 'package:agrocampo/core/network/connectivity_service.dart';
import 'package:agrocampo/core/sync/protocol/sync_contract.dart';
import 'package:agrocampo/core/sync/sync_coordinator.dart';
import 'package:agrocampo/core/sync/sync_gateway.dart';
import 'package:agrocampo/core/sync/sync_scheduler.dart';
import 'package:agrocampo/core/sync/sync_trigger_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

void main() {
  test(
    'coalesces concurrent triggers and cancels owner work on stop',
    () async {
      final database = createInMemoryDatabase();
      addTearDown(database.close);
      final gateway = _Gateway();
      final scheduler = _Scheduler();
      final connectivity = _Connectivity();
      final trigger = SyncTriggerCoordinator(
        SyncCoordinator(database, gateway),
        scheduler,
        connectivity,
      );

      final starting = trigger.start('owner-1');
      await gateway.started.future;
      final second = trigger.trigger(SyncTrigger.save);
      final third = trigger.trigger(SyncTrigger.resume);
      gateway.release.complete();
      await Future.wait([starting, second, third]);

      expect(gateway.pullCalls, 2);
      expect(scheduler.scheduled, contains('owner-1'));
      await trigger.stop('owner-1');
      expect(scheduler.cancelled, ['owner-1']);
      await connectivity.close();
    },
  );
}

final class _Gateway implements SyncGateway {
  final started = Completer<void>();
  final release = Completer<void>();
  int pullCalls = 0;

  @override
  Future<PullResult> pull({
    required String ownerId,
    required int afterCursor,
  }) async {
    pullCalls++;
    if (pullCalls == 1) {
      started.complete();
      await release.future;
    }
    return PullResult(nextCursor: afterCursor);
  }

  @override
  Future<PushResult> push({
    required String ownerId,
    required List<PushMutation> operations,
  }) async => const PushResult(operations: []);
}

final class _Scheduler implements SyncScheduler {
  final scheduled = <String>[];
  final cancelled = <String>[];
  @override
  Future<void> initialize() async {}
  @override
  Future<void> schedule({required String ownerId}) async =>
      scheduled.add(ownerId);
  @override
  Future<void> cancel({required String ownerId}) async =>
      cancelled.add(ownerId);
}

final class _Connectivity implements ConnectivityService {
  final controller = StreamController<ConnectionSignal>.broadcast();
  @override
  Stream<ConnectionSignal> watch() => controller.stream;
  Future<void> close() => controller.close();
}
