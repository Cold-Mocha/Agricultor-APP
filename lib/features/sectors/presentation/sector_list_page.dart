import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SectorListPage extends ConsumerWidget {
  const SectorListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(sessionControllerProvider).ownerId;
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Sectores',
      subtitle: 'Superficies y cultivos de tu parcela activa',
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin sesión',
              message: 'Inicia sesión para ver sectores.',
            )
          : StreamBuilder(
              stream:
                  (database.select(database.sectors)
                        ..where(
                          (row) =>
                              row.ownerId.equals(ownerId) &
                              row.deletedAt.isNull(),
                        )
                        ..orderBy([(row) => OrderingTerm.asc(row.number)]))
                      .watch(),
              builder: (context, snapshot) {
                final rows = snapshot.data ?? const [];
                if (rows.isEmpty) {
                  return const AgroEmptyState(
                    title: 'Sin sectores',
                    message: 'Delimita sectores en el mapa para comenzar a registrar labores.',
                  );
                }
                return ListView(
                  children: [
                    for (final sector in rows)
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${sector.number}'),
                          ),
                          title: Text(sector.name),
                          subtitle: Text(
                            '${sector.areaSquareMeters.toStringAsFixed(0)} m² · ${sector.kind}',
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
