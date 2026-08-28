import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/weather/presentation/weather_summary_card.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(sessionControllerProvider).ownerId;
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Inicio',
      subtitle: 'Trabajo de campo disponible sin conexión',
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin parcela activa',
              message: 'Inicia sesión para recuperar tu espacio local.',
            )
          : StreamBuilder(
              stream:
                  (database.select(database.parcels)..where(
                        (row) =>
                            row.ownerId.equals(ownerId) &
                            row.isActive.equals(true),
                      ))
                      .watchSingleOrNull(),
              builder: (context, snapshot) {
                final parcel = snapshot.data;
                if (parcel == null) {
                  return AgroEmptyState(
                    title: 'Crea tu primera parcela',
                    message: 'La parcela activa organiza sectores, cultivos y registros.',
                    action: FilledButton(
                      onPressed: () => context.push('/parcelas/nueva'),
                      child: const Text('Crear parcela'),
                    ),
                  );
                }
                return ListView(
                  children: [
                    WeatherSummaryCard(ownerId: ownerId),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.landscape_outlined),
                        title: Text(parcel.name),
                        subtitle: Text(parcel.locality ?? 'Sin localidad'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/parcelas'),
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.cloud_off_outlined),
                      title: Text('Modo local-first activo'),
                      subtitle: Text(
                        'Los cambios se respaldarán al recuperar conexión.',
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
