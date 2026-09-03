import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/sync/sync_trigger_coordinator.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:drift/drift.dart';
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
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Sincronización',
      subtitle: 'Tus datos locales siguen disponibles aunque no haya conexión.',
      child: StreamBuilder(
        stream: database.syncOutboxDao.watchPending(ownerId),
        builder: (context, snapshot) {
          final pending = snapshot.data?.length ?? 0;
          final rows = snapshot.data ?? const [];
          final retryable = rows
              .where((row) => row.state == 'retry_wait')
              .length;
          final blocked = rows.where((row) => row.state == 'blocked').length;
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
              StreamBuilder(
                stream: database.conflictDao.watchUnresolved(ownerId),
                builder: (context, conflicts) => ListTile(
                  leading: const Icon(Icons.compare_arrows_rounded),
                  title: const Text('Conflictos por resolver'),
                  trailing: Text('${conflicts.data?.length ?? 0}'),
                ),
              ),
              FutureBuilder(
                future:
                    (database.select(database.syncOutbox)
                          ..where(
                            (row) =>
                                row.ownerId.equals(ownerId) &
                                row.state.equals('done'),
                          )
                          ..orderBy([
                            (row) => OrderingTerm.desc(row.completedAt),
                          ])
                          ..limit(1))
                        .getSingleOrNull(),
                builder: (context, lastAck) => ListTile(
                  leading: const Icon(Icons.cloud_done_outlined),
                  title: const Text('Último respaldo confirmado'),
                  subtitle: Text(
                    lastAck.data?.completedAt?.toLocal().toString() ??
                        'Aún no hay confirmaciones remotas.',
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () async {
                  for (final row in rows.where(
                    (row) => row.state == 'retry_wait',
                  )) {
                    await database.syncOutboxDao.retryManually(
                      ownerId,
                      row.operationId,
                    );
                  }
                  await ref
                      .read(syncTriggerCoordinatorProvider)
                      .trigger(SyncTrigger.manual);
                },
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
