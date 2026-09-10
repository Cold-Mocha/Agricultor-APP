import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final laborFormControllerProvider = Provider<LaborFormController>(
  LaborFormController.new,
);

final class LaborFormController {
  LaborFormController(this._ref);

  final Ref _ref;

  Future<LaborSaveStatus> save(LaborFormInput input) {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) return Future.value(LaborSaveStatus.noSession);
    return _ref.read(laborsFacadeProvider).save(ownerId: ownerId, input: input);
  }
}
