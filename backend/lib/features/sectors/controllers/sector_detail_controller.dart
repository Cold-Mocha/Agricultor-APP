import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/features/auth/controllers/session_controller.dart';
import 'package:agrocampo_backend/features/context/controllers/agricultural_context_controller.dart';
import 'package:agrocampo_backend/features/crops/repositories/crop_seed_loader.dart';
import 'package:agrocampo_backend/features/sectors/dto/sector_ui_state.dart';
import 'package:agrocampo_backend/features/sectors/repositories/sector_repository.dart';
import 'package:agrocampo_backend/features/sectors/repositories/sector_summary_repository.dart';
import 'package:agrocampo_backend/features/sectors/services/sector_ui_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sectorDetailUiStateProvider = StreamProvider.autoDispose
    .family<SectorDetailUiState, String>((ref, sectorId) {
      final ownerId = ref.watch(unlockedOwnerIdProvider);
      final selectedSectorId = ref
          .watch(agriculturalContextControllerProvider)
          .sectorId;
      return SectorDetailController(
        ref,
        sectorId,
      ).watch(ownerId: ownerId, selectedSectorId: selectedSectorId);
    });

final sectorDetailControllerProvider = Provider.autoDispose
    .family<SectorDetailController, String>(
      (ref, sectorId) => SectorDetailController(ref, sectorId),
    );

final class SectorDetailController {
  SectorDetailController(this._ref, this.sectorId);

  final Ref _ref;
  final String sectorId;

  Stream<SectorDetailUiState> watch({
    required String? ownerId,
    required String? selectedSectorId,
  }) async* {
    if (ownerId == null) {
      yield const SectorDetailUiState.signedOut();
      return;
    }

    final database = _ref.read(appDatabaseProvider);
    try {
      await CropSeedLoader(database).seedIfEmpty();
    } on Object {
      // Sector data remains readable if catalog seeding is unavailable.
    }

    try {
      await for (final sector in SectorRepository(
        database,
      ).watchById(ownerId: ownerId, sectorId: sectorId)) {
        if (sector == null) {
          yield SectorDetailUiState.notFound(ownerId: ownerId);
          continue;
        }
        await for (final summaries in SectorSummaryRepository(
          database,
        ).watch(ownerId: ownerId, parcelId: sector.parcelId)) {
          final summary = summaries
              .where((item) => item.id == sector.id)
              .map(SectorUiMapper.fromSummary)
              .firstOrNull;
          yield SectorDetailUiState(
            status: SectorDetailStatus.ready,
            ownerId: ownerId,
            selectedSectorId: selectedSectorId,
            detail: SectorDetailRecordUiState(
              id: sector.id,
              parcelId: sector.parcelId,
              number: sector.number,
              kind: sector.kind,
              areaSquareMeters: sector.areaSquareMeters,
            ),
            summary: summary,
          );
        }
      }
    } on Object catch (error) {
      yield SectorDetailUiState(
        status: SectorDetailStatus.error,
        ownerId: ownerId,
        selectedSectorId: selectedSectorId,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> ensureContextSelected() async {
    final context = _ref.read(agriculturalContextControllerProvider);
    if (context.sectorId == sectorId) return;
    await _ref
        .read(agriculturalContextControllerProvider.notifier)
        .selectSector(sectorId);
  }
}
