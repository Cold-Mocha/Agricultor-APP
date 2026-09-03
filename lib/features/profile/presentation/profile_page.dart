import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/routing/app_routes.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/agro_settings_group.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Perfil',
      subtitle: 'Tu identidad y preferencias',
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin sesión',
              message: 'Inicia sesión para abrir tu perfil.',
            )
          : StreamBuilder<LocalProfile?>(
              stream: (database.select(
                database.localProfiles,
              )..where((row) => row.id.equals(ownerId))).watchSingleOrNull(),
              builder: (context, profileSnapshot) => StreamBuilder<Parcel?>(
                stream:
                    (database.select(database.parcels)..where(
                          (row) =>
                              row.ownerId.equals(ownerId) &
                              row.isActive.equals(true) &
                              row.deletedAt.isNull(),
                        ))
                        .watchSingleOrNull(),
                builder: (context, parcelSnapshot) {
                  final profile = profileSnapshot.data;
                  final parcel = parcelSnapshot.data;
                  final displayName =
                      profile?.displayName ?? 'Nombre no configurado';
                  final locality = parcel?.locality?.trim().isNotEmpty == true
                      ? parcel!.locality!
                      : 'Ubicación no configurada';
                  return ListView(
                    key: const PageStorageKey('profile-scroll'),
                    children: [
                      _ProfileHeader(
                        displayName: displayName,
                        email: profile?.emailDisplay,
                        locality: locality,
                        onEdit: () =>
                            context.push(AppRoutes.profilePersonalInformation),
                      ),
                      const SizedBox(height: AgroSpacing.lg),
                      AgroSettingsGroup(
                        title: 'Cuenta',
                        children: [
                          AgroSettingsTile(
                            icon: Icons.badge_outlined,
                            title: 'Información personal',
                            subtitle: 'Nombre visible y dato de acceso',
                            onTap: () => context.push(
                              AppRoutes.profilePersonalInformation,
                            ),
                          ),
                          AgroSettingsTile(
                            icon: Icons.location_on_outlined,
                            title: 'Ubicación',
                            subtitle: 'Parcela activa y localidad',
                            value: locality,
                            onTap: () => context.push(AppRoutes.parcels),
                          ),
                        ],
                      ),
                      const SizedBox(height: AgroSpacing.lg),
                      AgroSettingsGroup(
                        title: 'Preferencias',
                        children: [
                          AgroSettingsTile(
                            icon: Icons.notifications_outlined,
                            title: 'Notificaciones',
                            subtitle: 'Alertas meteorológicas y recordatorios',
                            onTap: () =>
                                context.push(AppRoutes.profileNotifications),
                          ),
                          AgroSettingsTile(
                            icon: Icons.language_outlined,
                            title: 'Idioma',
                            subtitle: 'Idioma de la aplicación',
                            value: 'Español (Chile)',
                            onTap: () =>
                                context.push(AppRoutes.profileLanguage),
                          ),
                          AgroSettingsTile(
                            icon: Icons.fingerprint,
                            title: 'Seguridad y biometría',
                            subtitle: 'Desbloqueo en este dispositivo',
                            onTap: () =>
                                context.push(AppRoutes.profileSecurity),
                          ),
                          AgroSettingsTile(
                            icon: Icons.light_mode_outlined,
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
                            icon: Icons.help_outline,
                            title: 'Ayuda y soporte',
                            subtitle: 'Uso en terreno y datos offline',
                            onTap: () => context.push(AppRoutes.profileHelp),
                          ),
                          AgroSettingsTile(
                            icon: Icons.contact_support_outlined,
                            title: 'Contacto',
                            subtitle: 'Estado del canal de atención',
                            onTap: () => context.push(AppRoutes.profileContact),
                          ),
                          AgroSettingsTile(
                            icon: Icons.privacy_tip_outlined,
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
                            icon: Icons.cloud_sync_outlined,
                            title: 'Estado del respaldo',
                            subtitle:
                                'Pendientes, errores y última sincronización',
                            onTap: () =>
                                context.push(AppRoutes.synchronization),
                          ),
                        ],
                      ),
                      const SizedBox(height: AgroSpacing.lg),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onPressed: () => _confirmSignOut(context, ref),
                        icon: const Icon(Icons.logout_outlined),
                        label: const Text('Cerrar sesión'),
                      ),
                      const SizedBox(height: AgroSpacing.lg),
                    ],
                  );
                },
              ),
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
    required this.locality,
    required this.onEdit,
  });

  final String displayName;
  final String? email;
  final String locality;
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
                  : const Icon(
                      Icons.person_outline,
                      size: AgroSizes.iconFeatured,
                    ),
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
                  const Text(
                    'Uso personal · propietario/a de la parcela activa',
                  ),
                  if (email case final value?) ...[
                    const SizedBox(height: AgroSpacing.xxs),
                    Text(value),
                  ],
                  const SizedBox(height: AgroSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: AgroSizes.iconStandard,
                      ),
                      const SizedBox(width: AgroSpacing.xxs),
                      Expanded(child: Text(locality)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Editar información personal',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }
}
