import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class HarvestContextUiState {
  const HarvestContextUiState({
    required this.seasonName,
    required this.cropName,
  });

  factory HarvestContextUiState.fromSummary(HarvestContextSummary summary) =>
      HarvestContextUiState(
        seasonName: summary.seasonName,
        cropName: summary.cropName,
      );

  final String seasonName;
  final String cropName;
}

final productionControllerProvider = Provider<ProductionController>(
  ProductionController.new,
);

final class ProductionController {
  ProductionController(this._ref);

  final Ref _ref;

  Future<HarvestContextUiState?> loadContext(String? sectorId) async {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) return null;
    final summary = await _ref
        .read(productionFacadeProvider)
        .loadContext(ownerId, sectorId);
    return summary == null ? null : HarvestContextUiState.fromSummary(summary);
  }

  Future<ProductionSaveStatus> save(ProductionFormInput input) {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) {
      return Future.value(ProductionSaveStatus.missingContext);
    }
    return _ref.read(productionFacadeProvider).save(ownerId, input);
  }
}
