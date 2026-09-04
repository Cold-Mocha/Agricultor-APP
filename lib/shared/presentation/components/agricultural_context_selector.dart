import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
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
              child: Padding(
                padding: const EdgeInsets.only(top: AgroSpacing.xs),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final textScale = MediaQuery.textScalerOf(context)
                            .scale(1);
                        final useHorizontalLayout =
                            constraints.hasBoundedWidth &&
                            constraints.maxWidth >= (compact ? 304 : 320) &&
                            textScale <= 1.3;
                        final parcelSelector = _selector(
                          key: const Key('active-parcel-selector'),
                          initialValue:
                              parcels.any(
                                (row) => row.id == agriculturalContext.parcelId,
                              )
                              ? agriculturalContext.parcelId
                              : null,
                          label: 'Parcela',
                          hint: 'Selecciona una parcela',
                          icon: Icons.landscape_outlined,
                          showLeadingIcon: !useHorizontalLayout,
                          items: [
                            for (final parcel in parcels)
                              DropdownMenuItem(
                                value: parcel.id,
                                child: Text(
                                  parcel.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(
                                    agriculturalContextControllerProvider
                                        .notifier,
                                  )
                                  .selectParcel(value);
                            }
                          },
                        );
                        final sectorSelector = _selector(
                          key: const Key('active-sector-selector'),
                          initialValue:
                              sectors.any(
                                (row) => row.id == agriculturalContext.sectorId,
                              )
                              ? agriculturalContext.sectorId
                              : null,
                          label: requireSector ? 'Sector requerido' : 'Sector',
                          hint: agriculturalContext.parcelId == null
                              ? 'Primero elige parcela'
                              : 'Selecciona un sector',
                          icon: Icons.grid_view_outlined,
                          showLeadingIcon: !useHorizontalLayout,
                          items: [
                            for (final sector in sectors)
                              DropdownMenuItem(
                                value: sector.id,
                                child: Text(
                                  sector.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                        );
                        if (useHorizontalLayout) {
                          return Row(
                            key: const Key('agricultural-context-row'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: parcelSelector),
                              const SizedBox(width: AgroSpacing.sm),
                              Expanded(child: sectorSelector),
                            ],
                          );
                        }
                        return Column(
                          key: const Key('agricultural-context-column'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            parcelSelector,
                            const SizedBox(height: AgroSpacing.sm),
                            sectorSelector,
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _selector({
    required Key key,
    required String? initialValue,
    required String label,
    required String hint,
    required IconData icon,
    required bool showLeadingIcon,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
  }) => DropdownButtonFormField<String>(
    key: key,
    isExpanded: true,
    initialValue: initialValue,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: showLeadingIcon ? Icon(icon) : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AgroSpacing.sm,
        vertical: AgroSpacing.sm,
      ),
    ),
    hint: Text(hint, maxLines: 1, overflow: TextOverflow.ellipsis),
    items: items,
    onChanged: onChanged,
  );
}
