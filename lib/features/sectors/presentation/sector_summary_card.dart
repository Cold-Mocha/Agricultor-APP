import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/sectors/data/sector_summary_repository.dart';
import 'package:agrocampo/shared/presentation/components/crop_pictogram.dart';
import 'package:flutter/material.dart';

final class SectorSummaryCard extends StatelessWidget {
  const SectorSummaryCard({
    required this.summary,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final SectorSummary summary;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (summary.statusLabel) {
      'Requiere revisar el respaldo' => Theme.of(context).colorScheme.error,
      'Sin cultivo asignado' => Theme.of(context).colorScheme.onSurfaceVariant,
      _ => Theme.of(context).colorScheme.primary,
    };
    final lastIrrigation = _dateLabel(context, summary.lastIrrigationAt);
    final lastRecord = _dateLabel(context, summary.lastRecordAt);
    final semantics =
        '${summary.displayName}. ${summary.cropLabel}. '
        '${summary.statusLabel}. Último riego $lastIrrigation. '
        'Último registro $lastRecord.';
    return Semantics(
      button: true,
      selected: selected,
      label: semantics,
      excludeSemantics: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AgroRadii.large),
          side: BorderSide(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AgroSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CropPictogram(
                  asset: summary.cropIconAsset,
                  colorToken: summary.cropColorToken,
                ),
                const SizedBox(width: AgroSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AgroSpacing.xxs),
                      Text(summary.cropLabel),
                      const SizedBox(height: AgroSpacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: AgroSpacing.xs),
                          Expanded(
                            child: Text(
                              summary.statusLabel,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AgroSpacing.xs),
                      Text(
                        'Último riego: $lastIrrigation · Último registro: $lastRecord',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (summary.syncState != 'synced') ...[
                        const SizedBox(height: AgroSpacing.xxs),
                        Row(
                          children: [
                            Icon(
                              summary.syncState == 'error' ||
                                      summary.syncState == 'conflict'
                                  ? Icons.cloud_off_outlined
                                  : Icons.cloud_upload_outlined,
                              size: AgroSizes.iconAuxiliary,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            const SizedBox(width: AgroSpacing.xxs),
                            Expanded(
                              child: Text(
                                summary.syncState == 'error' ||
                                        summary.syncState == 'conflict'
                                    ? 'El dato local sigue guardado; revisa el respaldo.'
                                    : 'Cambios por respaldar.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AgroSpacing.xs),
                const ExcludeSemantics(
                  child: Icon(Icons.chevron_right_outlined),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _dateLabel(BuildContext context, DateTime? value) {
    if (value == null) return 'sin registro';
    return MaterialLocalizations.of(context).formatShortDate(value.toLocal());
  }
}
