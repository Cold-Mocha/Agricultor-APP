import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/territory/presentation/formatters/sector_ui_mapper.dart';
import 'package:agrocampo/src/modules/territory/presentation/state/sector_ui_state.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:agrocampo/src/modules/territory/presentation/state/sector_ui_state.dart';

typedef TerritoryMapController = TerritoryMapFacade;

final territoryMapControllerProvider = territoryMapFacadeProvider;

final parcelControllerProvider = Provider.autoDispose<ParcelController>(
  (ref) => ParcelController(ref, ref.watch(parcelFacadeProvider)),
);

final class ParcelController {
  ParcelController(this._ref, this._facade);

  final Ref _ref;
  final ParcelFacade _facade;

  Stream<List<ParcelSummary>> watchAll(String ownerId) =>
      _facade.watchAll(ownerId);

  Stream<ParcelSummary?> watchActive(String ownerId) =>
      _facade.watchActive(ownerId);

  Future<ParcelSummary?> load(String id) => _facade.load(id);

  Future<String> save(ParcelFormInput input) async {
    final id = await _facade.save(input);
    if (input.isActive) {
      await _ref
          .read(agriculturalContextControllerProvider.notifier)
          .selectParcel(id);
    }
    return id;
  }

  Future<void> archive({
    required String ownerId,
    required String id,
    required bool archived,
  }) => _facade.archive(ownerId: ownerId, id: id, archived: archived);
}

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
    try {
      await for (final summaries
          in _ref
              .read(sectorListFacadeProvider)
              .watchSummaries(ownerId: ownerId, parcelId: parcelId)) {
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
        final history = await _ref
            .read(sectorListFacadeProvider)
            .recentHistory(ownerId: ownerId, parcelId: parcelId);
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
        await for (final summaries in facade.watchSummaries(
          ownerId: ownerId,
          parcelId: sector.parcelId,
        )) {
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
