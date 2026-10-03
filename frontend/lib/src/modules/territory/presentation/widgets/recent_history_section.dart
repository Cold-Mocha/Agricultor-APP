import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/territory/presentation/controllers/territory_controllers.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Latest records across the farmer's quadrants, shown at the end of Inicio.
final class RecentHistorySection extends ConsumerWidget {
  const RecentHistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sectorListUiStateProvider).asData?.value;
    if (state == null || state.status != SectorListStatus.ready) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AgroSectionHeader(
          title: 'Resumen del historial',
          subtitle: 'Últimos registros de tus cuadrantes.',
          actionLabel: 'Ver todo',
          onAction: () => context.push(AppRoutes.history),
        ),
        const SizedBox(height: AgroSpacing.sm),
        if (state.historyLoading)
          const LinearProgressIndicator()
        else if (state.history.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AgroSpacing.md),
              child: Text(
                'Aún no hay actividades registradas en tus cuadrantes.',
              ),
            ),
          )
        else
          for (final event in state.history)
            _HistoryPreviewRow(
              key: ValueKey(event.groupingKey),
              event: event,
              quadrantNumber: state.sectors
                  .where((sector) => sector.id == event.sectorId)
                  .map((sector) => sector.number)
                  .firstOrNull,
              onTap: () =>
                  context.push(AppRoutes.sectorHistory(event.sectorId)),
            ),
      ],
    );
  }
}

final class _HistoryPreviewRow extends StatelessWidget {
  const _HistoryPreviewRow({
    required this.event,
    required this.quadrantNumber,
    required this.onTap,
    super.key,
  });

  final SectorHistoryPreviewUiState event;
  final int? quadrantNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      minLeadingWidth: AgroSizes.touchTarget,
      leading: Icon(switch (event.type) {
        SectorHistoryType.labor => LucideIcons.circleCheckBig,
        SectorHistoryType.soil => LucideIcons.flaskConical,
        SectorHistoryType.cropAssignment => LucideIcons.leaf,
      }),
      title: Text(event.title),
      subtitle: Text(
        [
          if (quadrantNumber != null) 'Cuadrante $quadrantNumber',
          MaterialLocalizations.of(context)
              .formatShortDate(event.occurredAt.toLocal()),
          if (event.cropLabel != null) event.cropLabel!,
        ].join(' · '),
      ),
      trailing: const ExcludeSemantics(child: Icon(LucideIcons.chevronRight)),
      onTap: onTap,
    ),
  );
}
