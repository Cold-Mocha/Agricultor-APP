import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/profile/presentation/controllers/profile_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_settings_group.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final localMode = ref.watch(isLocalModeProvider);
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
                final displayName =
                    profile?.displayName ?? 'Nombre no configurado';
                return ListView(
                  key: const PageStorageKey('profile-scroll'),
                  children: [
                    _ProfileHeader(
                      displayName: displayName,
                      email: profile?.emailDisplay,
                      onEdit: () =>
                          context.push(AppRoutes.profilePersonalInformation),
                    ),
                    const SizedBox(height: AgroSpacing.lg),
                    AgroSettingsGroup(
                      title: 'Cuenta',
                      children: [
                        AgroSettingsTile(
                          icon: LucideIcons.idCard,
                          title: 'Información personal',
                          subtitle: 'Nombre visible y dato de acceso',
                          onTap: () => context.push(
                            AppRoutes.profilePersonalInformation,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AgroSpacing.lg),
                    AgroSettingsGroup(
                      title: 'Preferencias',
                      children: [
                        AgroSettingsTile(
                          icon: LucideIcons.bell,
                          title: 'Notificaciones',
                          subtitle: 'Alertas meteorológicas y recordatorios',
                          onTap: () =>
                              context.push(AppRoutes.profileNotifications),
                        ),
                        AgroSettingsTile(
                          icon: LucideIcons.languages,
                          title: 'Idioma',
                          subtitle: 'Idioma de la aplicación',
                          value: 'Español (Chile)',
                          onTap: () => context.push(AppRoutes.profileLanguage),
                        ),
                        AgroSettingsTile(
                          icon: LucideIcons.fingerprint,
                          title: 'Seguridad y biometría',
                          subtitle: 'Desbloqueo en este dispositivo',
                          onTap: () => context.push(AppRoutes.profileSecurity),
                        ),
                        AgroSettingsTile(
                          icon: LucideIcons.sun,
                          title: 'Tema',
                          subtitle: 'Apariencia disponible',
                          value: 'Claro',
                          onTap: () => context.push(AppRoutes.profileTheme),
                        ),
                      ],
                    ),
                    const SizedBox(height: AgroSpacing.lg),
                    AgroSettingsGroup(
                      title: 'Ayuda y privacidad',
                      children: [
                        AgroSettingsTile(
                          icon: LucideIcons.circleHelp,
                          title: 'Ayuda y soporte',
                          subtitle: 'Uso en terreno y datos offline',
                          onTap: () => context.push(AppRoutes.profileHelp),
                        ),
                        AgroSettingsTile(
                          icon: LucideIcons.circleHelp,
                          title: 'Contacto',
                          subtitle: 'Estado del canal de atención',
                          onTap: () => context.push(AppRoutes.profileContact),
                        ),
                        AgroSettingsTile(
                          icon: LucideIcons.shieldCheck,
                          title: 'Privacidad',
                          subtitle: 'Guardado local y respaldo',
                          onTap: () => context.push(AppRoutes.profilePrivacy),
                        ),
                      ],
                    ),
                    const SizedBox(height: AgroSpacing.lg),
                    AgroSettingsGroup(
                      title: 'Datos',
                      children: [
                        AgroSettingsTile(
                          icon: LucideIcons.cloudSync,
                          title: 'Estado del respaldo',
                          subtitle:
                              'Pendientes, errores y última sincronización',
                          onTap: () => context.push(AppRoutes.synchronization),
                        ),
                      ],
                    ),
                    const SizedBox(height: AgroSpacing.lg),
                    if (!localMode) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onPressed: () => _confirmSignOut(context, ref),
                        icon: const Icon(LucideIcons.logOut),
                        label: const Text('Cerrar sesión'),
                      ),
                      const SizedBox(height: AgroSpacing.lg),
                    ],
                  ],
                );
              },
            ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Tus datos locales no se eliminan. La sincronización de esta cuenta se detendrá hasta que vuelvas a ingresar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(sessionControllerProvider.notifier).signOut();
    }
  }
}

final class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.onEdit,
  });

  final String displayName;
  final String? email;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final configured = displayName != 'Nombre no configurado';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AgroSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: AgroSizes.iconFeatured,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: configured
                  ? Text(
                      String.fromCharCode(displayName.runes.first)
                          .toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    )
                  : const Icon(LucideIcons.user, size: AgroSizes.iconFeatured),
            ),
            const SizedBox(width: AgroSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AgroSpacing.xxs),
                  const Text('Uso personal · propietario/a de los cuadrantes'),
                  if (email case final value?) ...[
                    const SizedBox(height: AgroSpacing.xxs),
                    Text(value),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Editar información personal',
              onPressed: onEdit,
              icon: const Icon(LucideIcons.pencil),
            ),
          ],
        ),
      ),
    );
  }
}
