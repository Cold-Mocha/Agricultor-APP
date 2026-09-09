import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/territory/presentation/controllers/territory_controllers.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_action_tile.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_metric_card.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_section_header.dart';
import 'package:agrocampo/src/shared/design_system/components/crop_pictogram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class SectorDetailPage extends ConsumerWidget {
  const SectorDetailPage({required this.sectorId, super.key});

  final String sectorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sectorDetailUiStateProvider(sectorId));
    return state.when(
      loading: () => const AgroPage(
        title: 'Cuadrante',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => const AgroPage(
        title: 'Cuadrante',
        child: AgroEmptyState(
          title: 'Cuadrante no disponible',
          message: 'Puede haber sido eliminado o pertenecer a otra parcela.',
        ),
      ),
      data: (value) => _buildContent(context, ref, value),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SectorDetailUiState state,
  ) {
    switch (state.status) {
      case SectorDetailStatus.signedOut:
        return const AgroPage(
          title: 'Cuadrante',
          child: AgroEmptyState(
            title: 'Sin sesión',
            message: 'Inicia sesión para abrir este cuadrante.',
          ),
        );
      case SectorDetailStatus.notFound:
      case SectorDetailStatus.error:
        return const AgroPage(
          title: 'Cuadrante',
          child: AgroEmptyState(
            title: 'Cuadrante no disponible',
            message: 'Puede haber sido eliminado o pertenecer a otra parcela.',
          ),
        );
      case SectorDetailStatus.ready:
        final detail = state.detail;
        final summary = state.summary;
        if (detail == null || summary == null) {
          return const AgroPage(
            title: 'Cuadrante',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.selectedSectorId != detail.id) {
          Future<void>.microtask(
            () => ref
                .read(sectorDetailControllerProvider(sectorId))
                .ensureContextSelected(),
          );
        }
        return AgroPage(
          title: 'Cuadrante ${detail.number}',
          subtitle:
              '${detail.areaSquareMeters.toStringAsFixed(0)} m² · ${summary.statusLabel}',
          actions: [
            IconButton(
              tooltip: 'Abrir mapa de cuadrantes',
              onPressed: () =>
                  context.push(AppRoutes.quadrantMap(detail.parcelId)),
              icon: const Icon(Icons.map_outlined),
            ),
          ],
          child: ListView(
            key: ValueKey('quadrant-${detail.id}-scroll'),
            children: [
              _CropIdentityCard(
                summary: summary,
                onChangeCrop: () =>
                    context.push(AppRoutes.sectorRotation(detail.id)),
                onApiary: summary.isApiary
                    ? () => context.push(AppRoutes.sectorApiary(detail.id))
                    : null,
              ),
              const SizedBox(height: AgroSpacing.lg),
              const AgroSectionHeader(
                title: 'Estado del cuadrante',
                subtitle: 'Últimos datos guardados en el dispositivo.',
              ),
              const SizedBox(height: AgroSpacing.sm),
              AgroAdaptiveGrid(
                children: [
                  AgroMetricCard(
                    label: 'Superficie',
                    value: '${summary.areaSquareMeters.toStringAsFixed(0)} m²',
                    icon: Icons.straighten_outlined,
                  ),
                  AgroMetricCard(
                    label: 'Humedad del suelo',
                    value: summary.soilMoisturePercent == null
                        ? 'Sin medición'
                        : '${summary.soilMoisturePercent!.toStringAsFixed(0)} %',
                    icon: Icons.opacity_outlined,
                  ),
                  AgroMetricCard(
                    label: 'Último riego',
                    value: _date(context, summary.lastIrrigationAt),
                    icon: Icons.water_drop_outlined,
                  ),
                  AgroMetricCard(
                    label: 'Última medición',
                    value: _date(context, summary.lastSoilAt),
                    icon: Icons.science_outlined,
                  ),
                ],
              ),
              const SizedBox(height: AgroSpacing.lg),
              const AgroSectionHeader(
                title: 'Acciones',
                subtitle:
                    'El contexto de este cuadrante se mantiene en cada flujo.',
              ),
              const SizedBox(height: AgroSpacing.sm),
              AgroAdaptiveGrid(
                children: [
                  AgroActionTile(
                    icon: Icons.add_task_outlined,
                    label: 'Registrar labor',
                    onTap: () => context.push(
                      AppRoutes.registerFor(sectorId: detail.id),
                    ),
                  ),
                  AgroActionTile(
                    icon: Icons.water_drop_outlined,
                    label: 'Riego',
                    onTap: () => context.push(
                      AppRoutes.irrigationFor(sectorId: detail.id),
                    ),
                  ),
                  AgroActionTile(
                    icon: Icons.science_outlined,
                    label: 'Suelo',
                    onTap: () =>
                        context.push(AppRoutes.soilFor(sectorId: detail.id)),
                  ),
                  AgroActionTile(
                    icon: Icons.auto_awesome_outlined,
                    label: 'AgroIA',
                    onTap: () => context.push(AppRoutes.agroAi),
                  ),
                  AgroActionTile(
                    icon: Icons.eco_outlined,
                    label: 'Cambiar cultivo',
                    onTap: () =>
                        context.push(AppRoutes.sectorRotation(detail.id)),
                  ),
                  AgroActionTile(
                    icon: Icons.history_outlined,
                    label: 'Ver historial',
                    onTap: () =>
                        context.push(AppRoutes.sectorHistory(detail.id)),
                  ),
                ],
              ),
              const SizedBox(height: AgroSpacing.lg),
            ],
          ),
        );
    }
  }

  static String _date(BuildContext context, DateTime? value) => value == null
      ? 'Sin registro'
      : MaterialLocalizations.of(context).formatShortDate(value.toLocal());
}

final class _CropIdentityCard extends StatelessWidget {
  const _CropIdentityCard({
    required this.summary,
    required this.onChangeCrop,
    required this.onApiary,
  });

  final SectorCardUiState summary;
  final VoidCallback onChangeCrop;
  final VoidCallback? onApiary;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AgroSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CropPictogram(
                asset: summary.cropIconAsset,
                colorToken: summary.cropColorToken,
                semanticLabel: summary.cropLabel,
              ),
              const SizedBox(width: AgroSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.cropLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AgroSpacing.xxs),
                    Text(
                      summary.seasonLabel ?? 'Sin temporada asignada',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AgroSpacing.xs),
                    Text(summary.statusLabel),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AgroSpacing.sm),
          OutlinedButton.icon(
            onPressed: onChangeCrop,
            icon: const Icon(Icons.event_repeat_outlined),
            label: const Text('Cultivo y rotación'),
          ),
          if (onApiary case final action?) ...[
            const SizedBox(height: AgroSpacing.xs),
            OutlinedButton.icon(
              onPressed: action,
              icon: const Icon(Icons.hive_outlined),
              label: const Text('Registrar revisión apícola'),
            ),
          ],
        ],
      ),
    ),
  );
}
