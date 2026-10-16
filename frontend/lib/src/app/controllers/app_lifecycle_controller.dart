import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLifecycleControllerProvider = Provider<AppLifecycleController>(
  AppLifecycleController.new,
);

final class AppLifecycleController {
  AppLifecycleController(this._ref);

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
    await _ref.read(sessionControllerProvider.notifier).resumeOwner(ownerId);
  }
}
