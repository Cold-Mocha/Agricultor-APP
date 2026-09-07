import 'package:agrocampo_backend/core/config/backend_providers.dart';
import 'package:agrocampo_backend/features/auth/controllers/session_controller.dart';
import 'package:agrocampo_backend/features/context/controllers/agricultural_context_controller.dart';
import 'package:agrocampo_backend/features/crops/repositories/crop_seed_loader.dart';
import 'package:agrocampo_backend/features/history/domain/history_event.dart';
import 'package:agrocampo_backend/features/history/repositories/history_repository.dart';
import 'package:agrocampo_backend/features/sectors/dto/sector_ui_state.dart';
import 'package:agrocampo_backend/features/sectors/repositories/sector_summary_repository.dart';
import 'package:agrocampo_backend/features/sectors/services/sector_ui_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sectorListUiStateProvider = StreamProvider.autoDispose<SectorListUiState>(
  (ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final context = ref.watch(agriculturalContextControllerProvider);
    return SectorListController(ref).watch(
      ownerId: ownerId,
      parcelId: context.parcelId,
      selectedSectorId: context.sectorId,
    );
  },
);

final sectorListControllerProvider = Provider.autoDispose<SectorListController>(
  SectorListController.new,
);

final class SectorListController {
  SectorListController(this._ref);

  final Ref _ref;

  Stream<SectorListUiState> watch({
    required String? ownerId,
    required String? parcelId,
    required String? selectedSectorId,
  }) async* {
    if (ownerId == null) {
      yield const SectorListUiState.signedOut();
      return;
    }
    if (parcelId == null) {
      yield SectorListUiState.needsParcel(ownerId: ownerId);
      return;
    }

    final database = _ref.read(appDatabaseProvider);
    // Seeding is an idempotent local preparation step. The previous page did
    // not block the list when seeding failed, so preserve that behavior.
    try {
      await CropSeedLoader(database).seedIfEmpty();
    } on Object {
      // The local sector projection remains usable without the seed.
    }

    try {
      await for (final summaries in SectorSummaryRepository(
        database,
      ).watch(ownerId: ownerId, parcelId: parcelId)) {
        final sectors = summaries
            .map(SectorUiMapper.fromSummary)
            .toList(growable: false);
        yield SectorListUiState(
          status: SectorListStatus.ready,
          ownerId: ownerId,
          parcelId: parcelId,
          selectedSectorId: selectedSectorId,
          sectors: sectors,
          historyLoading: true,
        );

        final history = await HistoryRepository(
          database,
        ).list(HistoryFilter(ownerId: ownerId, parcelId: parcelId, limit: 3));
        yield SectorListUiState(
          status: SectorListStatus.ready,
          ownerId: ownerId,
          parcelId: parcelId,
          selectedSectorId: selectedSectorId,
          sectors: sectors,
          history: history
              .map(SectorUiMapper.fromHistory)
              .toList(growable: false),
        );
      }
    } on Object catch (error) {
      yield SectorListUiState(
        status: SectorListStatus.error,
        ownerId: ownerId,
        parcelId: parcelId,
        selectedSectorId: selectedSectorId,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> selectSector(String sectorId) => _ref
      .read(agriculturalContextControllerProvider.notifier)
      .selectSector(sectorId);
}
