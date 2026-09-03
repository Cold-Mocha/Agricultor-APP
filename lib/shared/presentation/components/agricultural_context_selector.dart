import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AgriculturalContextSelector extends ConsumerWidget {
  const AgriculturalContextSelector({
    this.requireSector = false,
    this.compact = false,
    super.key,
  });

  final bool requireSector;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agriculturalContext = ref.watch(
      agriculturalContextControllerProvider,
    );
    final database = ref.watch(appDatabaseProvider);
    final ownerId = agriculturalContext.ownerId;
    if (ownerId == null) return const SizedBox.shrink();
    return StreamBuilder(
      stream:
          (database.select(database.parcels)
                ..where(
                  (row) =>
                      row.ownerId.equals(ownerId) &
                      row.deletedAt.isNull() &
                      row.isArchived.equals(false),
                )
                ..orderBy([(row) => OrderingTerm.asc(row.name)]))
              .watch(),
      builder: (context, parcelSnapshot) {
        final parcels = parcelSnapshot.data ?? const [];
        return StreamBuilder(
          stream:
              (database.select(database.sectors)
                    ..where(
                      (row) =>
                          row.ownerId.equals(ownerId) &
                          row.parcelId.equals(
                            agriculturalContext.parcelId ?? '',
                          ) &
                          row.deletedAt.isNull(),
                    )
                    ..orderBy([(row) => OrderingTerm.asc(row.number)]))
                  .watch(),
          builder: (context, sectorSnapshot) {
            final sectors = sectorSnapshot.data ?? const [];
            return Semantics(
              label: 'Contexto agrícola activo',
              container: true,
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: compact ? 190 : 260,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      key: const Key('active-parcel-selector'),
                      initialValue:
                          parcels.any(
                            (row) => row.id == agriculturalContext.parcelId,
                          )
                          ? agriculturalContext.parcelId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Parcela',
                        prefixIcon: Icon(Icons.landscape_outlined),
                      ),
                      hint: const Text('Selecciona una parcela'),
                      items: [
                        for (final parcel in parcels)
                          DropdownMenuItem(
                            value: parcel.id,
                            child: Text(parcel.name),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(
                                agriculturalContextControllerProvider.notifier,
                              )
                              .selectParcel(value);
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: compact ? 190 : 260,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      key: const Key('active-sector-selector'),
                      initialValue:
                          sectors.any(
                            (row) => row.id == agriculturalContext.sectorId,
                          )
                          ? agriculturalContext.sectorId
                          : null,
                      decoration: InputDecoration(
                        labelText: requireSector
                            ? 'Sector requerido'
                            : 'Sector',
                        prefixIcon: const Icon(Icons.grid_view_outlined),
                      ),
                      hint: Text(
                        agriculturalContext.parcelId == null
                            ? 'Primero elige parcela'
                            : 'Selecciona un sector',
                      ),
                      items: [
                        for (final sector in sectors)
                          DropdownMenuItem(
                            value: sector.id,
                            child: Text(sector.name),
                          ),
                      ],
                      onChanged: agriculturalContext.parcelId == null
                          ? null
                          : (value) => ref
                                .read(
                                  agriculturalContextControllerProvider
                                      .notifier,
                                )
                                .selectSector(value),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
