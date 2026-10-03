import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/territory/territory_ui.dart';
import 'package:agrocampo/src/modules/weather/weather_ui.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_navigation_card.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_section_header.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final agriculturalContext = ref.watch(
      agriculturalContextControllerProvider,
    );
    final controller = ref.watch(contextOptionsControllerProvider);
    return AgroPage(
      title: 'Inicio',
      subtitle: 'Tu cuaderno de campo',
      actions: [
        IconButton(
          tooltip: 'Abrir perfil',
          onPressed: () => context.push(AppRoutes.profile),
          icon: const Icon(LucideIcons.circleUserRound),
        ),
      ],
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin sesión activa',
              message: 'Inicia sesión para recuperar tu espacio local.',
            )
          : StreamBuilder<List<ContextOption>>(
              stream: controller.watchSectors(ownerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final sectors = snapshot.data ?? const <ContextOption>[];
                if (sectors.isEmpty) {
                  return AgroEmptyState(
                    title: 'Dibuja tu primer cuadrante',
                    message: 'Los cuadrantes organizan cultivos, colmenas y registros.',
                    action: FilledButton(
                      onPressed: () => context.push(AppRoutes.quadrantMap),
                      child: const Text('Abrir mapa'),
                    ),
                  );
                }
                final sectorId = agriculturalContext.sectorId;
                final activeSector = sectors
                    .where((sector) => sector.id == sectorId)
                    .firstOrNull;
                return ListView(
                  key: const PageStorageKey('home-scroll'),
                  children: [
                    const AgroSectionHeader(
                      title: 'Tu campo hoy',
                      subtitle: 'Condiciones y accesos principales para trabajar en terreno.',
                    ),
                    const SizedBox(height: AgroSpacing.sm),
                    if (activeSector == null)
                      const AgriculturalContextSelector(compact: true)
                    else
                      WeatherSummaryCard(
                        ownerId: ownerId,
                        sectorId: activeSector.id,
                        locality: activeSector.name,
                      ),
                    const SizedBox(height: AgroSpacing.sm),
                    AgroNavigationCard(
                      icon: LucideIcons.layoutGrid,
                      title: 'Ver cuadrantes',
                      subtitle: [
                        sectors.length == 1
                            ? '1 cuadrante'
                            : '${sectors.length} cuadrantes',
                        activeSector?.name ?? 'ninguno seleccionado',
                      ].join(' · '),
                      onTap: () => context.go(AppRoutes.sectors),
                    ),
                    const SizedBox(height: AgroSpacing.lg),
                    const RecentHistorySection(),
                    const SizedBox(height: AgroSpacing.lg),
                  ],
                );
              },
            ),
    );
  }
}
