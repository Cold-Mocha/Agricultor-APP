import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/routing/app_routes.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/crops/data/crop_seed_loader.dart';
import 'package:agrocampo/features/sectors/data/sector_summary_repository.dart';
import 'package:agrocampo/shared/presentation/components/agro_action_tile.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_metric_card.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/agro_section_header.dart';
import 'package:agrocampo/shared/presentation/components/crop_pictogram.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class SectorDetailPage extends ConsumerWidget {
  const SectorDetailPage({required this.sectorId, super.key});

  final String sectorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final database = ref.watch(appDatabaseProvider);
    if (ownerId == null) {
      return const AgroPage(
        title: 'Cuadrante',
        child: AgroEmptyState(
          title: 'Sin sesión',
          message: 'Inicia sesión para abrir este cuadrante.',
        ),
      );
    }
    return FutureBuilder<Sector?>(
      future: _loadSector(database, ownerId),
      builder: (context, sectorSnapshot) {
        final sector = sectorSnapshot.data;
        if (sectorSnapshot.connectionState == ConnectionState.waiting) {
          return const AgroPage(
            title: 'Cuadrante',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (sector == null) {
          return const AgroPage(
            title: 'Cuadrante',
            child: AgroEmptyState(
              title: 'Cuadrante no disponible',
              message:
                  'Puede haber sido eliminado o pertenecer a otra parcela.',
            ),
          );
        }
        final selected = ref
            .watch(agriculturalContextControllerProvider)
            .sectorId;
        if (selected != sector.id) {
          Future<void>.microtask(
            () => ref
                .read(agriculturalContextControllerProvider.notifier)
                .selectSector(sector.id),
          );
        }
        return StreamBuilder<List<SectorSummary>>(
          stream: SectorSummaryRepository(database)
              .watch(ownerId: ownerId, parcelId: sector.parcelId),
          builder: (context, snapshot) {
            final matches = (snapshot.data ?? const <SectorSummary>[]).where(
              (summary) => summary.id == sector.id,
            );
            final summary = matches.firstOrNull;
            return AgroPage(
              title: 'Cuadrante ${sector.number}',
              subtitle:
                  '${sector.areaSquareMeters.toStringAsFixed(0)} m² · ${summary?.statusLabel ?? 'Leyendo datos locales'}',
              actions: [
                IconButton(
                  tooltip: 'Abrir mapa de cuadrantes',
                  onPressed: () =>
                      context.push(AppRoutes.quadrantMap(sector.parcelId)),
                  icon: const Icon(Icons.map_outlined),
                ),
              ],
              child: summary == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      key: ValueKey('quadrant-${sector.id}-scroll'),
                      children: [
                        _CropIdentityCard(
                          summary: summary,
                          onChangeCrop: () =>
                              context.push(AppRoutes.sectorRotation(sector.id)),
                          onApiary: summary.isApiary
                              ? () => context.push(
                                  AppRoutes.sectorApiary(sector.id),
                                )
                              : null,
                        ),
                        const SizedBox(height: AgroSpacing.lg),
                        const AgroSectionHeader(
                          title: 'Estado del cuadrante',
                          subtitle:
                              'Últimos datos guardados en el dispositivo.',
                        ),
                        const SizedBox(height: AgroSpacing.sm),
                        AgroAdaptiveGrid(
                          children: [
                            AgroMetricCard(
                              label: 'Superficie',
                              value:
                                  '${summary.areaSquareMeters.toStringAsFixed(0)} m²',
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
                          subtitle: 'El contexto de este cuadrante se mantiene en cada flujo.',
                        ),
                        const SizedBox(height: AgroSpacing.sm),
                        AgroAdaptiveGrid(
                          children: [
                            AgroActionTile(
                              icon: Icons.add_task_outlined,
                              label: 'Registrar labor',
                              onTap: () => context.push(
                                AppRoutes.registerFor(sectorId: sector.id),
                              ),
                            ),
                            AgroActionTile(
                              icon: Icons.water_drop_outlined,
                              label: 'Riego',
                              onTap: () => context.push(
                                AppRoutes.irrigationFor(sectorId: sector.id),
                              ),
                            ),
                            AgroActionTile(
                              icon: Icons.science_outlined,
                              label: 'Suelo',
                              onTap: () => context.push(
                                AppRoutes.soilFor(sectorId: sector.id),
                              ),
                            ),
                            AgroActionTile(
                              icon: Icons.auto_awesome_outlined,
                              label: 'AgroIA',
                              onTap: () => context.push(AppRoutes.agroAi),
                            ),
                            AgroActionTile(
                              icon: Icons.eco_outlined,
                              label: 'Cambiar cultivo',
                              onTap: () => context.push(
                                AppRoutes.sectorRotation(sector.id),
                              ),
                            ),
                            AgroActionTile(
                              icon: Icons.history_outlined,
                              label: 'Ver historial',
                              onTap: () => context.push(
                                AppRoutes.sectorHistory(sector.id),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AgroSpacing.lg),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  static String _date(BuildContext context, DateTime? value) => value == null
      ? 'Sin registro'
      : MaterialLocalizations.of(context).formatShortDate(value.toLocal());

  Future<Sector?> _loadSector(AppDatabase database, String ownerId) async {
    await CropSeedLoader(database).seedIfEmpty();
    return (database.select(database.sectors)..where(
          (row) =>
              row.ownerId.equals(ownerId) &
              row.id.equals(sectorId) &
              row.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }
}

final class _CropIdentityCard extends StatelessWidget {
  const _CropIdentityCard({
    required this.summary,
    required this.onChangeCrop,
    required this.onApiary,
  });

  final SectorSummary summary;
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
