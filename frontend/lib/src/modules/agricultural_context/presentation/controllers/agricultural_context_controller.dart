import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ContextOptionsController = ContextOptionsQueries;

final contextOptionsControllerProvider = contextOptionsQueriesProvider;

/// Name of the active quadrant, for headers that say what is being edited.
final activeSectorNameProvider = StreamProvider.autoDispose<String?>((ref) {
  final context = ref.watch(agriculturalContextControllerProvider);
  final ownerId = context.ownerId;
  final sectorId = context.sectorId;
  if (ownerId == null || sectorId == null) return Stream.value(null);
  return ref
      .watch(contextOptionsControllerProvider)
      .watchSectors(ownerId)
      .map(
        (sectors) =>
            sectors.where((sector) => sector.id == sectorId).firstOrNull?.name,
      );
});

final agriculturalContextControllerProvider =
    NotifierProvider<AgriculturalContextController, AgriculturalContext>(
      AgriculturalContextController.new,
    );

final class AgriculturalContextController
    extends Notifier<AgriculturalContext> {
  @override
  AgriculturalContext build() {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    if (ownerId == null) return const AgriculturalContext();
    Future.microtask(() => restore(ownerId));
    return AgriculturalContext.restoring(ownerId);
  }

  Future<void> restore(String ownerId) async {
    final restored = await ref
        .read(agriculturalContextFacadeProvider)
        .restore(ownerId);
    if (state.ownerId == ownerId) state = restored;
  }

  Future<void> selectSector(String? sectorId) async {
    state = await ref
        .read(agriculturalContextFacadeProvider)
        .selectSector(state, sectorId);
  }

  Future<void> selectSeason(String? seasonId) async {
    state = await ref
        .read(agriculturalContextFacadeProvider)
        .selectSeason(state, seasonId);
  }

  Future<void> selectAssignment(String? assignmentId) async {
    state = await ref
        .read(agriculturalContextFacadeProvider)
        .selectAssignment(state, assignmentId);
  }
}
