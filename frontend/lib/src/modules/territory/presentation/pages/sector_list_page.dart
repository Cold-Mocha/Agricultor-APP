import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/territory/presentation/controllers/territory_controllers.dart';
import 'package:agrocampo/src/modules/territory/presentation/widgets/quadrant_map_preview.dart';
import 'package:agrocampo/src/modules/territory/presentation/widgets/sector_summary_card.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class SectorListPage extends ConsumerWidget {
  const SectorListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sectorListUiStateProvider);
    final signedIn = state.asData?.value.ownerId != null;
    return AgroPage(
      title: 'Cuadrantes',
      subtitle: 'Tus sectores de cultivo y apicultura',
      actions: [
        IconButton(
          tooltip: 'Abrir mapa de cuadrantes',
          onPressed: signedIn
              ? () => context.push(AppRoutes.quadrantMap)
              : null,
          icon: const Icon(LucideIcons.map),
        ),
      ],
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const AgroEmptyState(
          title: 'No se pudieron leer los cuadrantes',
          message: 'Los datos locales siguen guardados. Vuelve a abrir esta sección.',
        ),
        data: (value) => _buildContent(context, ref, value),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SectorListUiState state,
  ) {
    switch (state.status) {
      case SectorListStatus.signedOut:
        return const AgroEmptyState(
          title: 'Sin sesión',
          message: 'Inicia sesión para ver tus cuadrantes.',
        );
      case SectorListStatus.error:
        return const AgroEmptyState(
          title: 'No se pudieron leer los cuadrantes',
          message: 'Los datos locales siguen guardados. Vuelve a abrir esta sección.',
        );
      case SectorListStatus.ready:
        return _readyContent(context, ref, state);
    }
  }

  Widget _readyContent(
    BuildContext context,
    WidgetRef ref,
    SectorListUiState state,
  ) {
    return ListView(
      key: const PageStorageKey('quadrants-scroll'),
      children: [
        const AgroSectionHeader(
          title: 'Tus cuadrantes',
          subtitle: 'Cultivo, estado y actividad reciente en un vistazo.',
        ),
        const SizedBox(height: AgroSpacing.sm),
        if (state.sectors.isEmpty)
          AgroEmptyState(
            title: 'Aún no hay cuadrantes',
            message: 'Delimita el primero en el mapa para comenzar a registrar labores.',
            action: FilledButton.icon(
              onPressed: () => context.push(AppRoutes.quadrantMap),
              icon: const Icon(LucideIcons.penTool),
              label: const Text('Delimitar en el mapa'),
            ),
          )
        else
          for (final sector in state.sectors) ...[
            SectorSummaryCard(
              key: ValueKey(sector.id),
              summary: sector,
              selected: sector.id == state.selectedSectorId,
              onTap: () async {
                await ref
                    .read(sectorListControllerProvider)
                    .selectSector(sector.id);
                if (context.mounted) {
                  context.push(AppRoutes.sector(sector.id));
                }
              },
            ),
            const SizedBox(height: AgroSpacing.xs),
          ],
        const SizedBox(height: AgroSpacing.md),
        const AgroSectionHeader(
          title: 'Mapa de cuadrantes',
          subtitle: 'Ubica visualmente los sectores guardados.',
        ),
        const SizedBox(height: AgroSpacing.sm),
        QuadrantMapPreview(
          sectors: state.sectors,
          onTap: () => context.push(AppRoutes.quadrantMap),
        ),
        const SizedBox(height: AgroSpacing.lg),
      ],
    );
  }
}
