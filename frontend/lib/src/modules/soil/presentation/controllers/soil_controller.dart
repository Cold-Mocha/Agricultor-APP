import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final soilMeasurementControllerProvider = Provider<SoilMeasurementController>(
  SoilMeasurementController.new,
);

final class SoilMeasurementController {
  SoilMeasurementController(this._ref);

  final Ref _ref;

  Future<bool> save({
    required String sectorId,
    required SoilMeasurementInput input,
  }) async {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) return false;
    return _ref
        .read(soilFacadeProvider)
        .save(ownerId: ownerId, sectorId: sectorId, input: input);
  }
}
