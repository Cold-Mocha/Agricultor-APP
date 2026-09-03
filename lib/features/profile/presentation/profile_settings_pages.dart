import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/weather/data/weather_alert_service.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ProfilePersonalInformationPage extends ConsumerStatefulWidget {
  const ProfilePersonalInformationPage({super.key});

  @override
  ConsumerState<ProfilePersonalInformationPage> createState() =>
      _ProfilePersonalInformationPageState();
}

final class _ProfilePersonalInformationPageState
    extends ConsumerState<ProfilePersonalInformationPage> {
  final _name = TextEditingController();
  String? _loadedOwnerId;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Información personal',
      subtitle: 'Identidad visible en este dispositivo',
      child: ownerId == null
          ? const Center(child: Text('Inicia sesión para editar tu perfil.'))
          : StreamBuilder<LocalProfile?>(
              stream: (database.select(
                database.localProfiles,
              )..where((row) => row.id.equals(ownerId))).watchSingleOrNull(),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                if (_loadedOwnerId != ownerId &&
                    snapshot.connectionState != ConnectionState.waiting) {
                  _loadedOwnerId = ownerId;
                  _name.text = profile?.displayName ?? '';
                }
                return ListView(
                  children: [
                    TextField(
                      key: const ValueKey('profile-display-name'),
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        labelText: 'Nombre visible',
                        helperText:
                            'Se guarda localmente y se usa en tu perfil.',
                      ),
                    ),
                    const SizedBox(height: AgroSpacing.md),
                    _ReadOnlyValue(
                      label: 'Correo de acceso',
                      value: profile?.emailDisplay ?? 'No disponible',
                    ),
                    const SizedBox(height: AgroSpacing.md),
                    FilledButton(
                      onPressed: _saving ? null : () => _save(ownerId),
                      child: Text(_saving ? 'Guardando…' : 'Guardar cambios'),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Future<void> _save(String ownerId) async {
    final value = _name.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un nombre visible.')),
      );
      return;
    }
    setState(() => _saving = true);
    final database = ref.read(appDatabaseProvider);
    final current = await (database.select(
      database.localProfiles,
    )..where((row) => row.id.equals(ownerId))).getSingleOrNull();
    await database
        .into(database.localProfiles)
        .insertOnConflictUpdate(
          LocalProfilesCompanion.insert(
            id: ownerId,
            displayName: value,
            emailDisplay: Value(current?.emailDisplay),
            locale: Value(current?.locale ?? 'es_CL'),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil guardado en este dispositivo.')),
    );
  }
}

final class ProfileNotificationsPage extends ConsumerWidget {
  const ProfileNotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Notificaciones',
      subtitle: 'Avisos que puedes controlar',
      child: ownerId == null
          ? const Center(child: Text('Inicia sesión para ver esta opción.'))
          : ListView(
              children: [
                StreamBuilder<AppPreference?>(
                  stream:
                      (database.select(database.appPreferences)..where(
                            (row) =>
                                row.ownerId.equals(ownerId) &
                                row.key.equals('weather_alerts_enabled'),
                          ))
                          .watchSingleOrNull(),
                  builder: (context, snapshot) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.notifications_outlined),
                    title: const Text('Alertas meteorológicas'),
                    subtitle: const Text(
                      'Los avisos se consultan cuando hay conexión. El registro local sigue disponible.',
                    ),
                    value: snapshot.data?.value == 'true',
                    onChanged: (enabled) =>
                        WeatherAlertService(database)
                            .setEnabled(ownerId, enabled),
                  ),
                ),
                const _InformationCard(
                  icon: Icons.alarm_outlined,
                  title: 'Recordatorios de labores',
                  message: 'Se administran desde Más > Recordatorios y funcionan como avisos locales del dispositivo.',
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
    return AgroPage(
      title: 'Seguridad',
      subtitle: 'Acceso y desbloqueo del dispositivo',
      child: ListView(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Desbloqueo biométrico'),
            subtitle: const Text(
              'Usa la biometría configurada en este dispositivo después de iniciar sesión.',
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
          const _InformationCard(
            icon: Icons.lock_outline,
            title: 'Datos locales protegidos',
            message: 'La sesión se conserva con almacenamiento seguro. Cerrar sesión detiene la sincronización de esta cuenta.',
          ),
        ],
      ),
    );
  }
}

enum ProfileInformationKind { language, theme, help, contact, privacy }

final class ProfileInformationPage extends StatelessWidget {
  const ProfileInformationPage({required this.kind, super.key});

  final ProfileInformationKind kind;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, items) = switch (kind) {
      ProfileInformationKind.language => (
        'Idioma',
        'Idioma disponible en esta versión',
        const [
          _InfoItem(
            Icons.language_outlined,
            'Español (Chile)',
            'Es el idioma activo del MVP. Aún no hay otros idiomas disponibles.',
          ),
        ],
      ),
      ProfileInformationKind.theme => (
        'Tema',
        'Apariencia de AgroCampo',
        const [
          _InfoItem(
            Icons.light_mode_outlined,
            'Modo claro',
            'Es el tema disponible actualmente. No se simula un modo oscuro que todavía no forma parte del MVP.',
          ),
        ],
      ),
      ProfileInformationKind.help => (
        'Ayuda y soporte',
        'Respuestas para trabajar en terreno',
        const [
          _InfoItem(
            Icons.cloud_off_outlined,
            '¿Puedo registrar sin conexión?',
            'Sí. Los registros se guardan primero en el dispositivo y se respaldan cuando vuelve la conexión.',
          ),
          _InfoItem(
            Icons.grid_view_outlined,
            '¿Dónde veo un cuadrante?',
            'Abre Sectores, toca su tarjeta y encontrarás sus métricas, labores e historial.',
          ),
          _InfoItem(
            Icons.sync_outlined,
            '¿Cómo reviso el respaldo?',
            'En Más > Sincronización puedes ver pendientes, errores y reintentar.',
          ),
        ],
      ),
      ProfileInformationKind.contact => (
        'Contacto',
        'Canal de atención',
        const [
          _InfoItem(
            Icons.contact_support_outlined,
            'Contacto no configurado',
            'Esta versión no incluye todavía un correo, teléfono o sitio oficial de soporte. No se mostrará un canal inventado.',
          ),
        ],
      ),
      ProfileInformationKind.privacy => (
        'Privacidad',
        'Cómo opera esta versión',
        const [
          _InfoItem(
            Icons.phone_android_outlined,
            'Trabajo local primero',
            'Tus registros se guardan en el dispositivo antes del respaldo en Supabase.',
          ),
          _InfoItem(
            Icons.account_circle_outlined,
            'Datos por cuenta',
            'La información agrícola se consulta separada por la cuenta autenticada.',
          ),
          _InfoItem(
            Icons.info_outline,
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
            icon: Icons.person_outline,
            title: 'Uso personal',
            message: 'AgroCampo organiza el cuaderno de campo de la persona propietaria. No incorpora empresas, trabajadores ni roles administrativos.',
          ),
          SizedBox(height: AgroSpacing.sm),
          _InformationCard(
            icon: Icons.tune_outlined,
            title: 'Preferencias personales',
            message: 'Notificaciones, biometría, idioma, tema y privacidad están reunidos en Perfil.',
          ),
        ],
      ),
    ),
  );
}

final class _ReadOnlyValue extends StatelessWidget {
  const _ReadOnlyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(labelText: label),
    child: Text(value),
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
