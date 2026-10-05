import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/auth/presentation/controllers/session_controller.dart';
import 'package:agrocampo/src/modules/profile/presentation/controllers/profile_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_navigation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final controller = ref.watch(profileControllerProvider);
    return AgroPage(
      title: 'Configuración',
      subtitle: 'Organización, respaldo y datos',
      child: ListView(
        key: const PageStorageKey('more-scroll'),
        children: [
          if (ownerId != null)
            StreamBuilder<ProfileUiState?>(
              stream: controller.watchProfile(ownerId),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AgroSpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: AgroSizes.iconFeatured,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          child: const Icon(
                            LucideIcons.user,
                            size: AgroSizes.iconFeatured,
                          ),
                        ),
                        const SizedBox(width: AgroSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Usuario',
                                style:
                                    Theme.of(context).textTheme.labelMedium,
                              ),
                              Text(
                                profile?.username ?? '',
                                style:
                                    Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: AgroSpacing.sm),
          AgroNavigationCard(
            icon: LucideIcons.circleUserRound,
            title: 'Tu perfil',
            subtitle: 'Cuenta, notificaciones y sesión',
            onTap: () => context.push(AppRoutes.profile),
          ),
          const SizedBox(height: AgroSpacing.sm),
          AgroNavigationCard(
            icon: LucideIcons.leaf,
            title: 'Catálogo de cultivos',
            subtitle: 'Especies oficiales y personalizadas',
            onTap: () => context.push(AppRoutes.cropCatalog),
          ),
          const SizedBox(height: AgroSpacing.sm),
          AgroNavigationCard(
            icon: LucideIcons.table,
            title: 'Exportar XLSX',
            subtitle: 'Respaldo legible de tus datos',
            onTap: () => context.push(AppRoutes.export),
          ),
          const SizedBox(height: AgroSpacing.sm),
          AgroNavigationCard(
            icon: LucideIcons.history,
            title: 'Historial agrícola',
            subtitle: 'Actividades, cultivos y mediciones',
            onTap: () => context.push(AppRoutes.history),
          ),
          const SizedBox(height: AgroSpacing.sm),
          AgroNavigationCard(
            icon: LucideIcons.bell,
            title: 'Recordatorios',
            subtitle: 'Alertas del campo y avisos de labores',
            onTap: () => context.push(AppRoutes.reminders),
          ),
        ],
      ),
    );
  }
}
