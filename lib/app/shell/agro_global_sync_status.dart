import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/network/connectivity_service.dart';
import 'package:agrocampo/shared/presentation/semantics/agro_semantics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingSyncCountProvider = StreamProvider.autoDispose.family<int, String>(
  (ref, ownerId) => ref
      .watch(appDatabaseProvider)
      .syncOutboxDao
      .watchPending(ownerId)
      .map((rows) => rows.length),
);

/// Stable, owner-scoped status that keeps offline and synchronization state
/// visible without blocking local work.
final class AgroGlobalSyncStatus extends ConsumerWidget
    implements PreferredSizeWidget {
  const AgroGlobalSyncStatus({required this.ownerId, super.key});

  final String ownerId;

  @override
  Size get preferredSize => const Size.fromHeight(AgroSizes.globalStatus);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityServiceProvider);
    final pending = ref.watch(pendingSyncCountProvider(ownerId)).value ?? 0;
    return StreamBuilder<ConnectionSignal>(
      stream: connectivity.watch(),
      initialData: ConnectionSignal.available,
      builder: (context, connectionSnapshot) {
        final offline = connectionSnapshot.data == ConnectionSignal.offline;
        final pendingLabel = pending == 1 ? '1 registro' : '$pending registros';
        final (icon, background, foreground, message) = switch ((
          offline,
          pending,
        )) {
          (true, 0) => (
            Icons.cloud_off_outlined,
            AgroColors.amberSoft,
            AgroColors.amberDark,
            'Sin conexión · puedes seguir registrando.',
          ),
          (true, final count) => (
            Icons.cloud_off_outlined,
            AgroColors.amberSoft,
            AgroColors.amberDark,
            'Sin conexión · $pendingLabel pendiente${count == 1 ? '' : 's'}.',
          ),
          (false, 0) => (
            Icons.cloud_done_outlined,
            AgroColors.greenSoft,
            AgroColors.brandDark,
            'Con conexión · respaldo al día.',
          ),
          (false, final count) => (
            Icons.cloud_upload_outlined,
            AgroColors.skySoft,
            AgroColors.skyDark,
            '$pendingLabel pendiente${count == 1 ? '' : 's'} de sincronización.',
          ),
        };
        return Semantics(
          container: true,
          label:
              '${AgroSemantics.connectionStatus}. ${AgroSemantics.synchronizationStatus}',
          value: message,
          child: ColoredBox(
            color: background,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AgroSizes.touchTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AgroSpacing.md),
                child: Row(
                  children: [
                    Icon(icon, color: foreground),
                    const SizedBox(width: AgroSpacing.sm),
                    Expanded(
                      child: Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
