import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/core/sync/sync_trigger_coordinator.dart';
import 'package:agrocampo_backend/features/auth/controllers/session_controller.dart';
import 'package:agrocampo_backend/features/auth/domain/session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLifecycleControllerProvider = Provider<AppLifecycleController>(
  AppLifecycleController._,
);

final class AppLifecycleController {
  AppLifecycleController._(this._ref);

  final Ref _ref;

  Future<void> restore() =>
      _ref.read(sessionControllerProvider.notifier).restore();

  Future<void> resume() async {
    final session = _ref.read(sessionControllerProvider);
    final ownerId = session.ownerId;
    if (ownerId == null ||
        (session.status != SessionStatus.signedIn &&
            session.status != SessionStatus.offline)) {
      return;
    }
    await _ref.read(cropAssignmentReconcilerProvider).reconcile(ownerId);
    await _ref.read(reminderReconcilerProvider).reconcile(ownerId);
    await _ref.read(syncTriggerCoordinatorProvider).trigger(SyncTrigger.resume);
  }
}
