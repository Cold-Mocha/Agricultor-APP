import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/history/data/history_repository.dart';
import 'package:agrocampo/features/history/domain/history_event.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(sessionControllerProvider).ownerId;
    return AgroPage(
      title: 'Historial',
      subtitle: 'Eventos locales por parcela, sector y temporada',
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin historial',
              message: 'Inicia sesión para consultar registros locales.',
            )
          : FutureBuilder(
              future: HistoryRepository(ref.watch(appDatabaseProvider))
                  .list(HistoryFilter(ownerId: ownerId)),
              builder: (context, snapshot) {
                final events = snapshot.data ?? const <HistoryEvent>[];
                if (events.isEmpty) {
                  return const AgroEmptyState(
                    title: 'Sin registros',
                    message:
                        'Las LABORES locales aparecerán aquí inmediatamente.',
                  );
                }
                return ListView(
                  children: [
                    for (final event in events)
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(event.title),
                        subtitle: Text(
                          event.detail ?? event.occurredAt.toLocal().toString(),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
