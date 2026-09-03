import 'dart:async';

import 'package:agrocampo/core/network/connectivity_service.dart';
import 'package:agrocampo/core/sync/sync_coordinator.dart';
import 'package:agrocampo/core/sync/sync_scheduler.dart';

enum SyncTrigger { unlock, save, resume, connectivity, manual, background }

final class SyncTriggerCoordinator {
  SyncTriggerCoordinator(
    this._coordinator,
    this._scheduler,
    this._connectivity,
  );

  final SyncCoordinator? _coordinator;
  final SyncScheduler _scheduler;
  final ConnectivityService _connectivity;
  StreamSubscription<ConnectionSignal>? _connectionSubscription;
  String? _ownerId;
  bool _running = false;
  bool _rerun = false;

  Future<void> start(String ownerId) async {
    if (_ownerId != ownerId) {
      await _connectionSubscription?.cancel();
      _ownerId = ownerId;
      _connectionSubscription = _connectivity.watch().listen((signal) {
        if (signal == ConnectionSignal.available) {
          unawaited(trigger(SyncTrigger.connectivity));
        }
      });
    }
    await _scheduler.schedule(ownerId: ownerId);
    await trigger(SyncTrigger.unlock);
  }

  Future<void> trigger(SyncTrigger trigger) async {
    final ownerId = _ownerId;
    if (ownerId == null || _coordinator == null) return;
    if (_running) {
      _rerun = true;
      return;
    }
    _running = true;
    try {
      do {
        _rerun = false;
        try {
          await _coordinator.synchronize(ownerId);
        } on Object {
          await _scheduler.schedule(ownerId: ownerId);
        }
      } while (_rerun && _ownerId == ownerId);
    } finally {
      _running = false;
    }
  }

  Future<void> stop(String ownerId) async {
    if (_ownerId == ownerId) {
      _ownerId = null;
      _rerun = false;
      await _connectionSubscription?.cancel();
      _connectionSubscription = null;
    }
    await _scheduler.cancel(ownerId: ownerId);
  }
}
