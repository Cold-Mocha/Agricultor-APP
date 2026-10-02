import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/sync_status/presentation/controllers/sync_status_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo/src/shared/design_system/feedback/agro_feedback.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class SyncStatusPage extends ConsumerWidget {
  const SyncStatusPage({this.ownerIdOverride, super.key});

  final String? ownerIdOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId =
        ownerIdOverride ?? ref.watch(sessionControllerProvider).ownerId;
    if (ownerId == null) {
      return const AgroPage(
        title: 'Sincronización',
        child: AgroEmptyState(
          title: 'Sin sesión local',
          message: 'Inicia sesión para ver el respaldo.',
        ),
      );
    }
    if (ref.watch(isLocalModeProvider)) {
      return const AgroPage(
        title: 'Sincronización',
        subtitle: 'Modo local · tus datos se guardan en este dispositivo.',
        child: AgroEmptyState(
          title: 'Respaldo en la nube desactivado',
          message: 'Disponible al activar el respaldo en la nube. Para guardar una copia, usa Más > Exportar XLSX.',
        ),
      );
    }
    final controller = ref.watch(syncStatusControllerProvider);
    return AgroPage(
      title: 'Sincronización',
      subtitle: 'Tus datos locales siguen disponibles aunque no haya conexión.',
      child: StreamBuilder<SyncStatusUiState>(
        stream: controller.watchPending(ownerId),
        builder: (context, snapshot) {
          final state = snapshot.data ?? const SyncStatusUiState();
          final pending = state.pending;
          final retryable = state.retryable;
          final blocked = state.blocked;
          return ListView(
            children: [
              ListTile(
                leading: const Icon(LucideIcons.cloudUpload),
                title: const Text('Cambios pendientes'),
                trailing: Text('$pending'),
              ),
              if (retryable > 0)
                ListTile(
                  leading: const Icon(LucideIcons.clock),
                  title: const Text('Esperando reintento'),
                  subtitle: const Text(
                    'Tus cambios siguen guardados localmente.',
                  ),
                  trailing: Text('$retryable'),
                ),
              if (blocked > 0)
                ListTile(
                  leading: const Icon(LucideIcons.circleAlert),
                  title: const Text('Cambios que necesitan atención'),
                  trailing: Text('$blocked'),
                ),
              StreamBuilder<int>(
                stream: controller.watchConflictCount(ownerId),
                builder: (context, conflicts) => ListTile(
                  leading: const Icon(LucideIcons.gitCompareArrows),
                  title: const Text('Conflictos por resolver'),
                  trailing: Text('${conflicts.data ?? 0}'),
                ),
              ),
              FutureBuilder<DateTime?>(
                future: controller.loadLastConfirmation(ownerId),
                builder: (context, lastAck) => ListTile(
                  leading: const Icon(LucideIcons.cloudCheck),
                  title: const Text('Último respaldo confirmado'),
                  subtitle: Text(
                    lastAck.data == null
                        ? 'Aún no hay confirmaciones remotas.'
                        : _dateTime(context, lastAck.data!),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: AgroFeedback.tap(
                  context,
                  () => controller.retry(ownerId),
                ),
                icon: const Icon(LucideIcons.refreshCw),
                label: const Text('Sincronizar ahora'),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _dateTime(BuildContext context, DateTime value) {
  final local = value.toLocal();
  final localizations = MaterialLocalizations.of(context);
  return '${localizations.formatMediumDate(local)} · '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
}
