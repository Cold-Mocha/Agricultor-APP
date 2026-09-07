import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/backend_providers.dart';
import '../../auth/controllers/session_controller.dart';
import '../domain/apiary_inspection_input.dart';
import '../repositories/apiary_repository.dart';

final apiaryInspectionControllerProvider = Provider<ApiaryInspectionController>(
  ApiaryInspectionController.new,
);

final class ApiaryInspectionController {
  ApiaryInspectionController(this._ref);
  final Ref _ref;
  Future<bool> save({
    required String sectorId,
    required ApiaryInspectionInput input,
  }) async {
    final ownerId = _ref.read(sessionControllerProvider).ownerId;
    if (ownerId == null) return false;
    await ApiaryRepository(_ref.read(appDatabaseProvider))
        .save(ownerId: ownerId, sectorId: sectorId, input: input);
    return true;
  }
}
