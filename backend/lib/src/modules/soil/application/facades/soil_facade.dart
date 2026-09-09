import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/soil/domain/entities/soil_measurement.dart';
import 'package:agrocampo_backend/src/modules/soil/infrastructure/persistence/soil_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final soilFacadeProvider = Provider<SoilFacade>(SoilFacade.new);

final class SoilFacade {
  SoilFacade(this._ref);
  final Ref _ref;

  Future<bool> save({
    required String ownerId,
    required String sectorId,
    required SoilMeasurementInput input,
  }) async {
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
