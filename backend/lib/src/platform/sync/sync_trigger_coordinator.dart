import 'dart:async';

import 'package:agrocampo_backend/src/composition/sync_scheduler.dart';
import 'package:agrocampo_backend/src/platform/network/connectivity_service.dart';
import 'package:agrocampo_backend/src/platform/sync/sync_coordinator.dart';

enum SyncTrigger { unlock, save, resume, connectivity, manual, background }

final class SyncTriggerCoordinator {
  SyncTriggerCoordinator(
    this._coordinator,
    this._scheduler,
    this._connectivity, {
    this._pendingWork,
    this.saveDebounce = const Duration(seconds: 2),
    this.retryInterval = const Duration(minutes: 2),
  });

  final SyncCoordinator? _coordinator;
  final SyncScheduler _scheduler;
  final ConnectivityService _connectivity;

  /// Count of operations still waiting to be pushed for an owner.
  final Stream<int> Function(String ownerId)? _pendingWork;

  /// Groups several saves made in a row into a single synchronization.
  final Duration saveDebounce;

  /// While work is pending, synchronization is retried at this pace.
  final Duration retryInterval;

  StreamSubscription<ConnectionSignal>? _connectionSubscription;
  StreamSubscription<int>? _pendingSubscription;
  Timer? _saveTimer;
  Timer? _retryTimer;
  int _lastPending = 0;
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
      await _pendingSubscription?.cancel();
      _lastPending = 0;
      // Without a remote there is nothing to push, so the queue is not watched.
      if (_coordinator != null) {
        _pendingSubscription = _pendingWork?.call(ownerId).listen(_onPending);
      }
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

  /// New local work is pushed shortly after it is saved, and retried while
  /// it stays pending, without the farmer pressing "Sincronizar ahora".
  void _onPending(int count) {
    if (count > _lastPending) {
      _saveTimer?.cancel();
      _saveTimer = Timer(
        saveDebounce,
        () => unawaited(trigger(SyncTrigger.save)),
      );
    }
    _lastPending = count;
    if (count == 0) {
      _retryTimer?.cancel();
      _retryTimer = null;
    } else {
      _retryTimer ??= Timer.periodic(
        retryInterval,
        (_) => unawaited(trigger(SyncTrigger.background)),
      );
    }
  }

  Future<void> stop(String ownerId) async {
    if (_ownerId == ownerId) {
      _ownerId = null;
      _rerun = false;
      await _connectionSubscription?.cancel();
      _connectionSubscription = null;
      await _pendingSubscription?.cancel();
      _pendingSubscription = null;
      _saveTimer?.cancel();
      _saveTimer = null;
      _retryTimer?.cancel();
      _retryTimer = null;
      _lastPending = 0;
    }
    await _scheduler.cancel(ownerId: ownerId);
  }
}
