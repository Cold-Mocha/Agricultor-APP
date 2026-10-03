import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/territory/presentation/formatters/sector_ui_mapper.dart';
import 'package:agrocampo/src/modules/territory/presentation/state/sector_ui_state.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:agrocampo/src/modules/territory/presentation/state/sector_ui_state.dart';

typedef TerritoryMapController = TerritoryMapFacade;

final territoryMapControllerProvider = territoryMapFacadeProvider;

final sectorListUiStateProvider = StreamProvider.autoDispose<SectorListUiState>(
  (ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final context = ref.watch(agriculturalContextControllerProvider);
    return SectorListController(ref)
        .watch(ownerId: ownerId, selectedSectorId: context.sectorId);
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
    required String? selectedSectorId,
  }) async* {
    if (ownerId == null) {
      yield const SectorListUiState.signedOut();
      return;
    }
    try {
      await for (final summaries
          in _ref.read(sectorListFacadeProvider).watchSummaries(ownerId)) {
        final sectors = summaries
            .map(SectorUiMapper.fromSummary)
            .toList(growable: false);
        yield SectorListUiState(
          status: SectorListStatus.ready,
          ownerId: ownerId,
          selectedSectorId: selectedSectorId,
          sectors: sectors,
          historyLoading: true,
        );
        final history = await _ref
            .read(sectorListFacadeProvider)
            .recentHistory(ownerId);
        yield SectorListUiState(
          status: SectorListStatus.ready,
          ownerId: ownerId,
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
        selectedSectorId: selectedSectorId,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> selectSector(String sectorId) => _ref
      .read(agriculturalContextControllerProvider.notifier)
      .selectSector(sectorId);
}

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
    final facade = _ref.read(sectorDetailFacadeProvider(sectorId));
    try {
      await for (final sector in facade.watchSector(ownerId)) {
        if (sector == null) {
          yield SectorDetailUiState.notFound(ownerId: ownerId);
          continue;
        }
        await for (final summaries in facade.watchSummaries(ownerId)) {
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

  Future<String?> loadName(String ownerId) async =>
      (await _ref
              .read(sectorDetailFacadeProvider(sectorId))
              .loadSector(ownerId))
          ?.name;

  Future<void> rename({required String ownerId, required String name}) => _ref
      .read(sectorDetailFacadeProvider(sectorId))
      .rename(ownerId: ownerId, name: name);

  Future<void> delete(String ownerId) async {
    // Deleting makes the detail page stop watching this auto-disposed
    // provider, so everything is read before the first await.
    final facade = _ref.read(sectorDetailFacadeProvider(sectorId));
    final context = _ref.read(agriculturalContextControllerProvider.notifier);
    final wasActive =
        _ref.read(agriculturalContextControllerProvider).sectorId == sectorId;
    await facade.delete(ownerId);
    if (wasActive) await context.selectSector(null);
  }

  Future<void> ensureContextSelected() async {
    final context = _ref.read(agriculturalContextControllerProvider);
    if (context.sectorId == sectorId) return;
    await _ref
        .read(agriculturalContextControllerProvider.notifier)
        .selectSector(sectorId);
  }
}
