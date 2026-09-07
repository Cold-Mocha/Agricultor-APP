import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                leading: const Icon(Icons.cloud_upload_outlined),
                title: const Text('Cambios pendientes'),
                trailing: Text('$pending'),
              ),
              if (retryable > 0)
                ListTile(
                  leading: const Icon(Icons.schedule_rounded),
                  title: const Text('Esperando reintento'),
                  subtitle: const Text(
                    'Tus cambios siguen guardados localmente.',
                  ),
                  trailing: Text('$retryable'),
                ),
              if (blocked > 0)
                ListTile(
                  leading: const Icon(Icons.error_outline_rounded),
                  title: const Text('Cambios que necesitan atención'),
                  trailing: Text('$blocked'),
                ),
              StreamBuilder<int>(
                stream: controller.watchConflictCount(ownerId),
                builder: (context, conflicts) => ListTile(
                  leading: const Icon(Icons.compare_arrows_rounded),
                  title: const Text('Conflictos por resolver'),
                  trailing: Text('${conflicts.data ?? 0}'),
                ),
              ),
              FutureBuilder<DateTime?>(
                future: controller.loadLastConfirmation(ownerId),
                builder: (context, lastAck) => ListTile(
                  leading: const Icon(Icons.cloud_done_outlined),
                  title: const Text('Último respaldo confirmado'),
                  subtitle: Text(
                    lastAck.data?.toLocal().toString() ??
                        'Aún no hay confirmaciones remotas.',
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => controller.retry(ownerId),
                icon: const Icon(Icons.sync_rounded),
                label: const Text('Sincronizar ahora'),
              ),
            ],
          );
        },
      ),
    );
  }
}
