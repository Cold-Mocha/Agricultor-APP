import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/routing/app_routes.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/features/weather/presentation/weather_summary_card.dart';
import 'package:agrocampo/shared/presentation/components/agro_action_tile.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_navigation_card.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/agro_section_header.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final agriculturalContext = ref.watch(
      agriculturalContextControllerProvider,
    );
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Inicio',
      subtitle: 'Tu cuaderno de campo',
      actions: [
        IconButton(
          tooltip: 'Abrir perfil',
          onPressed: () => context.push(AppRoutes.profile),
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin parcela activa',
              message: 'Inicia sesión para recuperar tu espacio local.',
            )
          : StreamBuilder(
              stream:
                  (database.select(database.parcels)..where(
                        (row) =>
                            row.ownerId.equals(ownerId) &
                            row.isActive.equals(true) &
                            row.deletedAt.isNull(),
                      ))
                      .watchSingleOrNull(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final parcel = snapshot.data;
                if (parcel == null) {
                  return AgroEmptyState(
                    title: 'Crea tu primera parcela',
                    message: 'La parcela activa organiza cuadrantes, cultivos y registros.',
                    action: FilledButton(
                      onPressed: () => context.push(AppRoutes.newParcel),
                      child: const Text('Crear parcela'),
                    ),
                  );
                }
                final locality = parcel.locality?.trim();
                final sectorId = agriculturalContext.sectorId;
                return ListView(
                  key: const PageStorageKey('home-scroll'),
                  children: [
                    const AgroSectionHeader(
                      title: 'Tu parcela hoy',
                      subtitle: 'Condiciones y accesos principales para trabajar en terreno.',
                    ),
                    const SizedBox(height: AgroSpacing.sm),
                    if (locality == null || locality.isEmpty)
                      _MissingLocalityCard(
                        parcelName: parcel.name,
                        onTap: () =>
                            context.push(AppRoutes.editParcel(parcel.id)),
                      )
                    else
                      WeatherSummaryCard(
                        ownerId: ownerId,
                        parcelId: parcel.id,
                        locality: locality,
                        onEditLocality: () =>
                            context.push(AppRoutes.editParcel(parcel.id)),
                      ),
                    const SizedBox(height: AgroSpacing.sm),
                    AgroNavigationCard(
                      icon: Icons.grid_view_outlined,
                      title: 'Ver cuadrantes',
                      subtitle:
                          '${parcel.name} · ${locality == null || locality.isEmpty ? 'sin ubicación configurada' : locality}',
                      onTap: () => context.go(AppRoutes.sectors),
                    ),
                    const SizedBox(height: AgroSpacing.lg),
                    const AgroSectionHeader(
                      title: 'Labores',
                      subtitle:
                          'Registra directamente la tarea que realizaste.',
                    ),
                    const SizedBox(height: AgroSpacing.sm),
                    AgroAdaptiveGrid(
                      children: [
                        AgroActionTile(
                          icon: Icons.water_drop_outlined,
                          label: 'Riego',
                          description: 'Registrar o calcular',
                          onTap: () => context.push(
                            AppRoutes.irrigationFor(sectorId: sectorId),
                          ),
                        ),
                        AgroActionTile(
                          icon: Icons.science_outlined,
                          label: 'Suelo',
                          description: 'Ingresar mediciones',
                          onTap: () => context.push(
                            AppRoutes.soilFor(sectorId: sectorId),
                          ),
                        ),
                        AgroActionTile(
                          icon: Icons.compost_outlined,
                          label: 'Fertilización',
                          description: 'Producto, dosis y método',
                          onTap: () => context.push(
                            AppRoutes.labor(
                              LaborType.fertilization,
                              sectorId: sectorId,
                            ),
                          ),
                        ),
                        AgroActionTile(
                          icon: Icons.pest_control_outlined,
                          label: 'Control de enfermedades y plagas',
                          description: 'Tratamiento y objetivo',
                          onTap: () => context.push(
                            AppRoutes.labor(
                              LaborType.diseaseAndPestControl,
                              sectorId: sectorId,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AgroSpacing.lg),
                  ],
                );
              },
            ),
    );
  }
}

final class _MissingLocalityCard extends StatelessWidget {
  const _MissingLocalityCard({required this.parcelName, required this.onTap});

  final String parcelName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AgroSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_off_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AgroSpacing.sm),
              Expanded(
                child: Text(
                  parcelName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AgroSpacing.xs),
          const Text(
            'Agrega la localidad de la parcela para consultar el clima. Tus labores siguen disponibles sin conexión.',
          ),
          const SizedBox(height: AgroSpacing.sm),
          OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.edit_location_alt_outlined),
            label: const Text('Agregar ubicación'),
          ),
        ],
      ),
    ),
  );
}
