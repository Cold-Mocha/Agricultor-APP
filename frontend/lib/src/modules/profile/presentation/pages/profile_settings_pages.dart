import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/profile/presentation/controllers/profile_controller.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class ProfileNotificationsPage extends ConsumerWidget {
  const ProfileNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final controller = ref.watch(profileControllerProvider);
    return AgroPage(
      title: 'Notificaciones',
      subtitle: 'Avisos que puedes controlar',
      child: ownerId == null
          ? const Center(child: Text('Inicia sesión para ver esta opción.'))
          : ListView(
              children: [
                StreamBuilder<bool>(
                  stream: controller.watchWeatherAlertsEnabled(ownerId),
                  builder: (context, snapshot) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(LucideIcons.bell),
                    title: const Text('Alertas meteorológicas'),
                    subtitle: const Text(
                      'Los avisos se consultan cuando hay conexión.',
                    ),
                    value: snapshot.data ?? false,
                    onChanged: (enabled) =>
                        controller.setWeatherAlertsEnabled(ownerId, enabled),
                  ),
                ),
                const _InformationCard(
                  icon: LucideIcons.alarmClock,
                  title: 'Alertas y recordatorios',
                  message: 'Fin de temporada, helada, temperaturas y labores se configuran en Configuración > Recordatorios.',
                ),
              ],
            ),
    );
  }
}

final class ProfileSecurityPage extends ConsumerWidget {
  const ProfileSecurityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final localMode = ref.watch(isLocalModeProvider);
    return AgroPage(
      title: 'Seguridad',
      subtitle: 'Acceso y desbloqueo del dispositivo',
      child: ListView(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(LucideIcons.fingerprint),
            title: const Text('Desbloqueo biométrico'),
            subtitle: Text(
              localMode
                  ? 'Usa la biometría configurada en este dispositivo al abrir AgroCampo.'
                  : 'Usa la biometría configurada en este dispositivo después de iniciar sesión.',
            ),
            value: session.biometricEnabled,
            onChanged: session.ownerId == null
                ? null
                : (enabled) async {
                    final accepted = await ref
                        .read(sessionControllerProvider.notifier)
                        .setBiometricEnabled(enabled);
                    if (!context.mounted || accepted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La biometría no está disponible o no está configurada en el dispositivo.',
                        ),
                      ),
                    );
                  },
          ),
          _InformationCard(
            icon: LucideIcons.lock,
            title: 'Datos protegidos',
            message: localMode
                ? 'Tus datos se guardan sólo en este dispositivo, con almacenamiento seguro.'
                : 'La sesión se conserva con almacenamiento seguro hasta que la cierres.',
          ),
        ],
      ),
    );
  }
}

final class ProfileThemePage extends ConsumerWidget {
  const ProfileThemePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final controller = ref.watch(profileControllerProvider);
    return AgroPage(
      title: 'Tema',
      subtitle: 'Apariencia de AgroCampo',
      child: ownerId == null
          ? const Center(child: Text('Inicia sesión para ver esta opción.'))
          : ListView(
              children: [
                StreamBuilder<bool>(
                  stream: controller.watchDarkModeEnabled(ownerId),
                  builder: (context, snapshot) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(LucideIcons.moon),
                    title: const Text('Modo oscuro'),
                    subtitle: const Text(
                      'Se aplica de inmediato en toda la aplicación.',
                    ),
                    value: snapshot.data ?? false,
                    onChanged: (enabled) =>
                        controller.setDarkModeEnabled(ownerId, enabled),
                  ),
                ),
                const _InformationCard(
                  icon: LucideIcons.smartphone,
                  title: 'Preferencia de este dispositivo',
                  message: 'El tema se guarda en este dispositivo y no se sincroniza con otros.',
                ),
              ],
            ),
    );
  }
}

enum ProfileInformationKind { language, help, contact, privacy }

final class ProfileInformationPage extends ConsumerWidget {
  const ProfileInformationPage({required this.kind, super.key});

  final ProfileInformationKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localMode = ref.watch(isLocalModeProvider);
    final (title, subtitle, items) = switch (kind) {
      ProfileInformationKind.language => (
        'Idioma',
        'Idioma disponible en esta versión',
        const [
          _InfoItem(
            LucideIcons.languages,
            'Español (Chile)',
            'Es el idioma activo del MVP. Aún no hay otros idiomas disponibles.',
          ),
        ],
      ),
      ProfileInformationKind.help => (
        'Ayuda y soporte',
        'Respuestas para trabajar en terreno',
        [
          _InfoItem(
            LucideIcons.cloudOff,
            '¿Puedo registrar sin conexión?',
            localMode
                ? 'Sí. Todos los registros se guardan en este dispositivo.'
                : 'Sí. Los registros se guardan y se respaldan solos cuando hay conexión.',
          ),
          _InfoItem(
            LucideIcons.layoutGrid,
            '¿Dónde veo un cuadrante?',
            'Abre Sectores, toca su tarjeta y encontrarás sus métricas, labores e historial.',
          ),
          const _InfoItem(
            LucideIcons.fileSpreadsheet,
            '¿Cómo respaldo mis datos?',
            'En Configuración > Exportar XLSX puedes guardar una copia legible de tus datos.',
          ),
        ],
      ),
      ProfileInformationKind.contact => (
        'Contacto',
        'Canal de atención',
        const [
          _InfoItem(
            LucideIcons.circleHelp,
            'Contacto no configurado',
            'Esta versión no incluye todavía un correo, teléfono o sitio oficial de soporte. No se mostrará un canal inventado.',
          ),
        ],
      ),
      ProfileInformationKind.privacy => (
        'Privacidad',
        'Cómo opera esta versión',
        [
          if (localMode) ...const [
            _InfoItem(
              LucideIcons.smartphone,
              'Datos en este dispositivo',
              'Tus registros se guardan sólo en este dispositivo; no se envían a la nube.',
            ),
          ] else ...const [
            _InfoItem(
              LucideIcons.smartphone,
              'Respaldo en Supabase',
              'Tus registros se respaldan solos en Supabase.',
            ),
            _InfoItem(
              LucideIcons.circleUserRound,
              'Datos por cuenta',
              'La información agrícola se consulta separada por la cuenta autenticada.',
            ),
          ],
          _InfoItem(
            LucideIcons.info,
            'Resumen informativo',
            'Este texto describe el comportamiento del MVP y no reemplaza una política legal publicada.',
          ),
        ],
      ),
    };
    return AgroPage(
      title: title,
      subtitle: subtitle,
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AgroSpacing.sm),
        itemBuilder: (context, index) => _InformationCard(
          icon: items[index].icon,
          title: items[index].title,
          message: items[index].message,
        ),
      ),
    );
  }
}

final class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) => const AgroPage(
    title: 'Configuración',
    subtitle: 'Alcance y opciones disponibles',
    child: SingleChildScrollView(
      child: Column(
        children: [
          _InformationCard(
            icon: LucideIcons.user,
            title: 'Uso personal',
            message: 'AgroCampo organiza el cuaderno de campo de la persona propietaria. No incorpora empresas, trabajadores ni roles administrativos.',
          ),
          SizedBox(height: AgroSpacing.sm),
          _InformationCard(
            icon: LucideIcons.slidersHorizontal,
            title: 'Preferencias personales',
            message: 'Notificaciones, biometría, idioma, tema y privacidad están reunidos en Perfil.',
          ),
        ],
      ),
    ),
  );
}

final class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AgroSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(child: Icon(icon)),
          const SizedBox(width: AgroSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AgroSpacing.xs),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

final class _InfoItem {
  const _InfoItem(this.icon, this.title, this.message);

  final IconData icon;
  final String title;
  final String message;
}
