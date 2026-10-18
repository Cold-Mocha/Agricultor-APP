import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/profile/presentation/controllers/profile_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_settings_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// master.md: Perfil y configuración (biometría oculta por orden del stakeholder).
final class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final controller = ref.watch(profileControllerProvider);
    return AgroPage(
      title: 'Perfil',
      subtitle: 'Tu identidad y preferencias',
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin sesión',
              message: 'Inicia sesión para abrir tu perfil.',
            )
          : StreamBuilder<ProfileUiState?>(
              stream: controller.watchProfile(ownerId),
              builder: (context, profileSnapshot) {
                final profile = profileSnapshot.data;
                return ListView(
                  key: const PageStorageKey('profile-scroll'),
                  children: [
                    _ProfileHeader(
                      username: profile?.displayName ?? 'Mi campo',
                    ),
                    const SizedBox(height: AgroSpacing.lg),
                    AgroSettingsGroup(
                      title: 'Preferencias',
                      children: [
                        AgroSettingsTile(
                          icon: LucideIcons.shield,
                          title: 'Seguridad',
                          subtitle: 'Protección de los datos del dispositivo',
                          onTap: () => context.push(AppRoutes.profileSecurity),
                        ),
                        AgroSettingsTile(
                          icon: LucideIcons.bell,
                          title: 'Notificaciones',
                          subtitle: 'Alertas de clima y recordatorios',
                          onTap: () =>
                              context.push(AppRoutes.profileNotifications),
                        ),
                        AgroSettingsTile(
                          icon: LucideIcons.sun,
                          title: 'Tema',
                          subtitle: 'Apariencia de la aplicación',
                          onTap: () => context.push(AppRoutes.profileTheme),
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

final class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.username});

  final String? username;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AgroSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: AgroSizes.iconFeatured,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            child: const Icon(LucideIcons.user, size: AgroSizes.iconFeatured),
          ),
          const SizedBox(width: AgroSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Usuario', style: Theme.of(context).textTheme.labelMedium),
                Text(
                  username ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
