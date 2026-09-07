import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/backend_providers.dart';
import '../../auth/controllers/session_controller.dart';
import '../domain/soil_measurement.dart';
import '../repositories/soil_repository.dart';

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
    final ownerId = _ref.read(sessionControllerProvider).ownerId;
    if (ownerId == null) return false;
    final database = _ref.read(appDatabaseProvider);
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return false;
    await SoilRepository(database)
        .save(ownerId: ownerId, sectorId: sector.id, input: input);
    return true;
  }
}
