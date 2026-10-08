import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/apiary/domain/entities/apiary_inspection_input.dart';
import 'package:agrocampo_backend/src/modules/apiary/infrastructure/persistence/apiary_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiaryInspectionFacadeProvider = Provider<ApiaryInspectionFacade>(
  (ref) => ApiaryInspectionFacade(ref.watch(appDatabaseProvider)),
);

final class ApiaryInspectionFacade {
  ApiaryInspectionFacade(this._database);
  final AppDatabase _database;
  Future<void> save({
    required String ownerId,
    required String sectorId,
    required ApiaryInspectionInput input,
  }) async {
    await ApiaryRepository(_database)
        .save(ownerId: ownerId, sectorId: sectorId, input: input);
  }
}
