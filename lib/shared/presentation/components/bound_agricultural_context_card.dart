import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/features/context/domain/agricultural_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class BoundAgriculturalContextCard extends ConsumerWidget {
  const BoundAgriculturalContextCard({
    required this.bound,
    required this.changed,
    required this.onRebind,
    super.key,
  });

  final BoundAgriculturalContext bound;
  final bool changed;
  final VoidCallback onRebind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(appDatabaseProvider);
    return FutureBuilder(
      future: Future.wait([
        if (bound.parcelId != null)
          (database.select(
            database.parcels,
          )..where((row) => row.id.equals(bound.parcelId!))).getSingleOrNull(),
        if (bound.sectorId != null)
          (database.select(
            database.sectors,
          )..where((row) => row.id.equals(bound.sectorId!))).getSingleOrNull(),
      ]),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const [];
        final parcel = rows.whereType<Parcel>().firstOrNull;
        final sector = rows.whereType<Sector>().firstOrNull;
        return Card(
          color: changed
              ? Theme.of(context).colorScheme.tertiaryContainer
              : null,
          child: ListTile(
            leading: Icon(changed ? Icons.info_outline : Icons.place_outlined),
            title: Text(
              [parcel?.name, sector?.name].whereType<String>().join(' · '),
            ),
            subtitle: Text(
              changed
                  ? 'La selección global cambió; este formulario conserva su contexto.'
                  : 'Contexto fijado para este formulario',
            ),
            trailing: changed
                ? TextButton(
                    onPressed: onRebind,
                    child: const Text('Usar actual'),
                  )
                : null,
          ),
        );
      },
    );
  }
}
