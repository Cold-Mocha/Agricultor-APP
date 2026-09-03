import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/routing/app_routes.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/crops/data/agricultural_season_repository.dart';
import 'package:agrocampo/features/crops/domain/agricultural_season.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class AgriculturalSeasonsPage extends ConsumerWidget {
  const AgriculturalSeasonsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final scope = ref.watch(agriculturalContextControllerProvider);
    final repository = AgriculturalSeasonRepository(
      ref.watch(appDatabaseProvider),
    );
    return AgroPage(
      title: 'Temporadas',
      subtitle: 'Organiza el trabajo sin borrar temporadas anteriores.',
      actions: [
        IconButton(
          tooltip: 'Nueva temporada',
          onPressed: ownerId == null || scope.parcelId == null
              ? null
              : () => context.push('${AppRoutes.seasons}/nueva'),
          icon: const Icon(Icons.add),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AgriculturalContextSelector(compact: true),
          const SizedBox(height: 12),
          Expanded(
            child: ownerId == null || scope.parcelId == null
                ? const AgroEmptyState(
                    title: 'Selecciona una parcela',
                    message: 'Cada temporada pertenece a una parcela.',
                  )
                : StreamBuilder<List<AgriculturalSeason>>(
                    stream: repository.watchByParcel(
                      ownerId: ownerId,
                      parcelId: scope.parcelId!,
                    ),
                    builder: (context, snapshot) {
                      final seasons = snapshot.data ?? const [];
                      if (seasons.isEmpty) {
                        return const AgroEmptyState(
                          title: 'Sin temporadas',
                          message: 'Crea una temporada para asociar cultivos a tus sectores.',
                        );
                      }
                      return ListView(
                        children: [
                          for (final season in seasons)
                            Card(
                              child: ListTile(
                                leading: Icon(_icon(season.status)),
                                title: Text(season.name),
                                subtitle: Text(
                                  '${_status(season.status)} · ${_date(season.startsOn)}${season.endsOn == null ? '' : ' — ${_date(season.endsOn!)}'} · ${_sync(season.syncState)}',
                                ),
                                selected: scope.seasonId == season.id,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  await ref
                                      .read(
                                        agriculturalContextControllerProvider
                                            .notifier,
                                      )
                                      .selectSeason(season.id);
                                  if (context.mounted) {
                                    context.push(
                                      '${AppRoutes.seasons}/${season.id}/editar',
                                    );
                                  }
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static IconData _icon(AgriculturalSeasonStatus status) => switch (status) {
    AgriculturalSeasonStatus.active => Icons.play_circle_outline,
    AgriculturalSeasonStatus.closed => Icons.check_circle_outline,
    AgriculturalSeasonStatus.planned => Icons.event_outlined,
  };

  static String _status(AgriculturalSeasonStatus status) => switch (status) {
    AgriculturalSeasonStatus.active => 'Activa',
    AgriculturalSeasonStatus.closed => 'Cerrada',
    AgriculturalSeasonStatus.planned => 'Planificada',
  };

  static String _sync(String value) =>
      value == 'synced' ? 'Sincronizada' : 'Local';
  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
