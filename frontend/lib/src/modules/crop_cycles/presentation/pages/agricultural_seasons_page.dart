import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/crop_cycles/presentation/controllers/crop_cycles_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class AgriculturalSeasonsPage extends ConsumerWidget {
  const AgriculturalSeasonsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final scope = ref.watch(agriculturalContextControllerProvider);
    final controller = ref.watch(cropsControllerProvider);
    return AgroPage(
      title: 'Temporadas',
      subtitle: switch (ref.watch(activeSectorNameProvider).value) {
        final name? => 'Configurando $name',
        null => 'Temporadas de este cuadrante.',
      },
      actions: [
        IconButton(
          tooltip: 'Nueva temporada',
          onPressed: ownerId == null || scope.sectorId == null
              ? null
              : () => context.push('${AppRoutes.seasons}/nueva'),
          icon: const Icon(LucideIcons.plus),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ownerId == null || scope.sectorId == null
                ? const AgroEmptyState(
                    title: 'Abre un cuadrante',
                    message: 'Configura sus temporadas desde Configurar temporada en cada cuadrante.',
                  )
                : StreamBuilder<List<AgriculturalSeason>>(
                    stream: controller.watchSeasons(
                      ownerId: ownerId,
                      sectorId: scope.sectorId!,
                    ),
                    builder: (context, snapshot) {
                      final seasons = snapshot.data ?? const [];
                      if (seasons.isEmpty) {
                        return const AgroEmptyState(
                          title: 'Sin temporadas',
                          message: 'Crea una temporada para asociar cultivos a este cuadrante.',
                        );
                      }
                      return ListView(
                        children: [
                          for (final season in seasons)
                            Card(
                              child: ListTile(
                                leading: Icon(_icon(season.status)),
                                title: Text(_range(season)),
                                subtitle: Text(_status(season.status)),
                                selected: scope.seasonId == season.id,
                                trailing: const Icon(LucideIcons.pencil),
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
    AgriculturalSeasonStatus.active => LucideIcons.circlePlay,
    AgriculturalSeasonStatus.closed => LucideIcons.circleCheck,
    AgriculturalSeasonStatus.planned => LucideIcons.calendar,
  };

  static String _status(AgriculturalSeasonStatus status) => switch (status) {
    AgriculturalSeasonStatus.active => 'Activa',
    AgriculturalSeasonStatus.closed => 'Cerrada',
    AgriculturalSeasonStatus.planned => 'Planificada',
  };

  static String _range(AgriculturalSeason season) =>
      '${_date(season.startsOn)}${season.endsOn == null ? '' : ' — ${_date(season.endsOn!)}'}';

  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
