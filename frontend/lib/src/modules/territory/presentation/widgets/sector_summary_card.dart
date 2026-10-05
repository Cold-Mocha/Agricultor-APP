import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/territory/presentation/state/sector_ui_state.dart';
import 'package:agrocampo/src/shared/design_system/components/crop_pictogram.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class SectorSummaryCard extends StatelessWidget {
  const SectorSummaryCard({
    required this.summary,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final SectorCardUiState summary;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (summary.statusLabel) {
      'Sin cultivo asignado' => Theme.of(context).colorScheme.onSurfaceVariant,
      _ => Theme.of(context).colorScheme.primary,
    };
    final semantics =
        '${summary.displayName}. ${summary.cropLabel}. '
        '${summary.statusLabel}.';
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
                  apiary: summary.isApiary,
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
                    ],
                  ),
                ),
                const SizedBox(width: AgroSpacing.xs),
                const ExcludeSemantics(child: Icon(LucideIcons.chevronRight)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
