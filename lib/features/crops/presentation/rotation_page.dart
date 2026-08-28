import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class RotationPage extends ConsumerWidget {
  const RotationPage({required this.sectorId, super.key});

  final String sectorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(appDatabaseProvider);
    return AgroPage(
      title: 'Rotación futura',
      subtitle: 'Planificar no cambia el cultivo vigente.',
      child: StreamBuilder(
        stream: (database.select(
          database.cropSeasons,
        )..where((row) => row.sectorId.equals(sectorId))).watch(),
        builder: (context, snapshot) {
          final seasons = snapshot.data ?? const [];
          if (seasons.isEmpty) {
            return const AgroEmptyState(
              title: 'Sin rotaciones planificadas',
              message: 'Agrega un cultivo y una fecha de inicio futura.',
            );
          }
          return ListView(
            children: [
              for (final season in seasons)
                ListTile(
                  leading: const Icon(Icons.event_repeat_outlined),
                  title: Text(season.cropId),
                  subtitle: Text(
                    '${season.status} · ${season.startsOn.toLocal()}',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
