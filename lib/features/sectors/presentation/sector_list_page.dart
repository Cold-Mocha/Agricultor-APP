import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/routing/app_routes.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/crops/data/crop_seed_loader.dart';
import 'package:agrocampo/features/history/data/history_repository.dart';
import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:agrocampo/features/sectors/data/sector_summary_repository.dart';
import 'package:agrocampo/features/sectors/presentation/quadrant_map_preview.dart';
import 'package:agrocampo/features/sectors/presentation/sector_summary_card.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/agro_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class SectorListPage extends ConsumerWidget {
  const SectorListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final agriculturalContext = ref.watch(
      agriculturalContextControllerProvider,
    );
    final database = ref.watch(appDatabaseProvider);
    final parcelId = agriculturalContext.parcelId;
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
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin sesión',
              message: 'Inicia sesión para ver tus cuadrantes.',
            )
          : parcelId == null
          ? const Column(
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
            )
          : FutureBuilder<void>(
              future: CropSeedLoader(database).seedIfEmpty(),
              builder: (context, seedSnapshot) =>
                  StreamBuilder<List<SectorSummary>>(
                    stream: SectorSummaryRepository(database)
                        .watch(ownerId: ownerId, parcelId: parcelId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const AgroEmptyState(
                          title: 'No se pudieron leer los cuadrantes',
                          message: 'Los datos locales siguen guardados. Vuelve a abrir esta sección.',
                        );
                      }
                      final sectors = snapshot.data ?? const [];
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
                          if (sectors.isEmpty)
                            AgroEmptyState(
                              title: 'Aún no hay cuadrantes',
                              message: 'Delimita el primero en el mapa para comenzar a registrar labores.',
                              action: FilledButton.icon(
                                onPressed: () => context.push(
                                  AppRoutes.quadrantMap(parcelId),
                                ),
                                icon: const Icon(Icons.draw_outlined),
                                label: const Text('Delimitar en el mapa'),
                              ),
                            )
                          else
                            for (final sector in sectors) ...[
                              SectorSummaryCard(
                                key: ValueKey(sector.id),
                                summary: sector,
                                selected:
                                    sector.id == agriculturalContext.sectorId,
                                onTap: () async {
                                  await ref
                                      .read(
                                        agriculturalContextControllerProvider
                                            .notifier,
                                      )
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
                            subtitle:
                                'Ubica visualmente los sectores guardados.',
                          ),
                          const SizedBox(height: AgroSpacing.sm),
                          QuadrantMapPreview(
                            sectors: sectors,
                            onTap: () =>
                                context.push(AppRoutes.quadrantMap(parcelId)),
                          ),
                          const SizedBox(height: AgroSpacing.lg),
                          AgroSectionHeader(
                            title: 'Resumen del historial',
                            subtitle: 'Últimos registros de esta parcela.',
                            actionLabel: 'Ver todo',
                            onAction: () => context.push(AppRoutes.history),
                          ),
                          const SizedBox(height: AgroSpacing.sm),
                          FutureBuilder<List<HistoryEvent>>(
                            future: HistoryRepository(database).list(
                              HistoryFilter(
                                ownerId: ownerId,
                                parcelId: parcelId,
                                limit: 3,
                              ),
                            ),
                            builder: (context, historySnapshot) {
                              final events = historySnapshot.data ?? const [];
                              if (historySnapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  events.isEmpty) {
                                return const LinearProgressIndicator();
                              }
                              if (events.isEmpty) {
                                return const Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(AgroSpacing.md),
                                    child: Text(
                                      'Aún no hay actividades registradas en esta parcela.',
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                children: [
                                  for (final event in events)
                                    _HistoryPreviewRow(
                                      key: ValueKey(event.groupingKey),
                                      event: event,
                                      quadrantNumber: sectors
                                          .where(
                                            (sector) =>
                                                sector.id == event.sectorId,
                                          )
                                          .map((sector) => sector.number)
                                          .firstOrNull,
                                      onTap: () => context.push(
                                        AppRoutes.sectorHistory(event.sectorId),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: AgroSpacing.lg),
                        ],
                      );
                    },
                  ),
            ),
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

  final HistoryEvent event;
  final int? quadrantNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      minLeadingWidth: AgroSizes.touchTarget,
      leading: Icon(switch (event.type) {
        HistoryEventType.labor => Icons.task_alt_outlined,
        HistoryEventType.soil => Icons.science_outlined,
        HistoryEventType.cropAssignment => Icons.eco_outlined,
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
