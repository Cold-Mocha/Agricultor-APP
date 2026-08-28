import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
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
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined),
                title: const Text('Cambios pendientes'),
                trailing: Text('$pending'),
              ),
              StreamBuilder(
                stream: database.conflictDao.watchUnresolved(ownerId),
                builder: (context, conflicts) => ListTile(
                  leading: const Icon(Icons.compare_arrows_rounded),
                  title: const Text('Conflictos por resolver'),
                  trailing: Text('${conflicts.data?.length ?? 0}'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
