import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/history/data/history_repository.dart';
import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({this.initialSectorId, super.key});
  final String? initialSectorId;

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

final class _HistoryPageState extends ConsumerState<HistoryPage> {
  HistoryEventType? _type;

  @override
  Widget build(BuildContext context) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final agriculturalContext = ref.watch(
      agriculturalContextControllerProvider,
    );
    final sectorId = widget.initialSectorId ?? agriculturalContext.sectorId;
    return AgroPage(
      title: 'Historial',
      subtitle: 'Línea temporal agrícola del sector',
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin historial',
              message: 'Inicia sesión para consultar registros locales.',
            )
          : Column(
              children: [
                const AgriculturalContextSelector(requireSector: true),
                const SizedBox(height: AgroSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chip(null, 'Todo'),
                      _chip(HistoryEventType.labor, 'Labores'),
                      _chip(HistoryEventType.cropAssignment, 'Cultivos'),
                      _chip(HistoryEventType.soil, 'Suelo'),
                    ],
                  ),
                ),
                const SizedBox(height: AgroSpacing.sm),
                Expanded(
                  child: sectorId == null
                      ? const AgroEmptyState(
                          title: 'Selecciona un sector',
                          message: 'El historial siempre muestra un contexto territorial explícito.',
                        )
                      : FutureBuilder<List<HistoryEvent>>(
                          future:
                              HistoryRepository(ref.watch(appDatabaseProvider))
                                  .list(
                                    HistoryFilter(
                                      ownerId: ownerId,
                                      parcelId: agriculturalContext.parcelId,
                                      sectorId: sectorId,
                                      seasonId: agriculturalContext.seasonId,
                                      type: _type,
                                    ),
                                  ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final events =
                                snapshot.data ?? const <HistoryEvent>[];
                            if (events.isEmpty) {
                              return const AgroEmptyState(
                                title: 'Sin registros para este filtro',
                                message: 'Las actividades offline aparecerán aquí inmediatamente.',
                              );
                            }
                            return ListView.builder(
                              itemCount: events.length,
                              itemBuilder: (_, index) {
                                final event = events[index];
                                final showHeader =
                                    index == 0 ||
                                    events[index - 1].seasonLabel !=
                                        event.seasonLabel;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (showHeader)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: AgroSpacing.md,
                                          bottom: AgroSpacing.xs,
                                        ),
                                        child: Text(
                                          event.seasonLabel ?? 'Sin temporada',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ),
                                    Card(
                                      child: ListTile(
                                        leading: Icon(_icon(event)),
                                        title: Text(event.title),
                                        subtitle: Text(
                                          [
                                            if (event.cropLabel != null)
                                              event.cropLabel!,
                                            if (event.detail != null &&
                                                event.detail!.isNotEmpty)
                                              event.detail!,
                                            _date(event.occurredAt),
                                          ].join(' · '),
                                        ),
                                        trailing: Tooltip(
                                          message: _syncLabel(event.syncState),
                                          child: Icon(
                                            event.syncState == 'synced'
                                                ? Icons.cloud_done_outlined
                                                : event.syncState == 'conflict'
                                                ? Icons.sync_problem_outlined
                                                : Icons.cloud_upload_outlined,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _chip(HistoryEventType? type, String label) => Padding(
    padding: const EdgeInsets.only(right: AgroSpacing.xs),
    child: FilterChip(
      label: Text(label),
      selected: _type == type,
      onSelected: (_) => setState(() => _type = type),
    ),
  );

  IconData _icon(HistoryEvent event) => switch (event.type) {
    HistoryEventType.labor => Icons.agriculture_outlined,
    HistoryEventType.cropAssignment => Icons.eco_outlined,
    HistoryEventType.soil => Icons.science_outlined,
  };

  String _syncLabel(String state) => switch (state) {
    'synced' => 'Sincronizado',
    'conflict' => 'Conflicto pendiente',
    _ => 'Guardado localmente; pendiente de sincronizar',
  };

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
