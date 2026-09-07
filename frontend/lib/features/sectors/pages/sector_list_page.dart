import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/sectors/widgets/quadrant_map_preview.dart';
import 'package:agrocampo/features/sectors/widgets/sector_summary_card.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/agro_section_header.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class SectorListPage extends ConsumerWidget {
  const SectorListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sectorListUiStateProvider);
    final current = state.asData?.value;
    final parcelId = current?.parcelId;
    return AgroPage(
      title: 'Cuadrantes',
      subtitle: 'Sectores de la parcela activa',
      actions: [
        IconButton(
          tooltip: 'Abrir mapa de cuadrantes',
          onPressed: parcelId == null
              ? null
              : () => context.push(AppRoutes.quadrantMap(parcelId)),
          icon: const Icon(Icons.map_outlined),
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
      case SectorListStatus.needsParcel:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AgriculturalContextSelector(compact: true),
            SizedBox(height: AgroSpacing.lg),
            Expanded(
              child: AgroEmptyState(
                title: 'Selecciona una parcela',
                message: 'Los cuadrantes se muestran por parcela activa.',
              ),
            ),
          ],
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
    final parcelId = state.parcelId!;
    return ListView(
      key: const PageStorageKey('quadrants-scroll'),
      children: [
        const AgriculturalContextSelector(compact: true),
        const SizedBox(height: AgroSpacing.lg),
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
              onPressed: () => context.push(AppRoutes.quadrantMap(parcelId)),
              icon: const Icon(Icons.draw_outlined),
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
          onTap: () => context.push(AppRoutes.quadrantMap(parcelId)),
        ),
        const SizedBox(height: AgroSpacing.lg),
        AgroSectionHeader(
          title: 'Resumen del historial',
          subtitle: 'Últimos registros de esta parcela.',
          actionLabel: 'Ver todo',
          onAction: () => context.push(AppRoutes.history),
        ),
        const SizedBox(height: AgroSpacing.sm),
        if (state.historyLoading)
          const LinearProgressIndicator()
        else if (state.history.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AgroSpacing.md),
              child: Text(
                'Aún no hay actividades registradas en esta parcela.',
              ),
            ),
          )
        else
          Column(
            children: [
              for (final event in state.history)
                _HistoryPreviewRow(
                  key: ValueKey(event.groupingKey),
                  event: event,
                  quadrantNumber: state.sectors
                      .where((sector) => sector.id == event.sectorId)
                      .map((sector) => sector.number)
                      .firstOrNull,
                  onTap: () =>
                      context.push(AppRoutes.sectorHistory(event.sectorId)),
                ),
            ],
          ),
        const SizedBox(height: AgroSpacing.lg),
      ],
    );
  }
}

final class _HistoryPreviewRow extends StatelessWidget {
  const _HistoryPreviewRow({
    required this.event,
    required this.quadrantNumber,
    required this.onTap,
    super.key,
  });

  final SectorHistoryPreviewUiState event;
  final int? quadrantNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      minLeadingWidth: AgroSizes.touchTarget,
      leading: Icon(switch (event.type) {
        SectorHistoryType.labor => Icons.task_alt_outlined,
        SectorHistoryType.soil => Icons.science_outlined,
        SectorHistoryType.cropAssignment => Icons.eco_outlined,
      }),
      title: Text(event.title),
      subtitle: Text(
        [
          if (quadrantNumber != null) 'Cuadrante $quadrantNumber',
          MaterialLocalizations.of(context)
              .formatShortDate(event.occurredAt.toLocal()),
          if (event.cropLabel != null) event.cropLabel!,
        ].join(' · '),
      ),
      trailing: const ExcludeSemantics(
        child: Icon(Icons.chevron_right_outlined),
      ),
      onTap: onTap,
    ),
  );
}
