import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/territory/presentation/controllers/territory_controllers.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_action_tile.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_metric_card.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_section_header.dart';
import 'package:agrocampo/src/shared/design_system/components/crop_pictogram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class SectorDetailPage extends ConsumerWidget {
  const SectorDetailPage({required this.sectorId, super.key});

  final String sectorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sectorDetailUiStateProvider(sectorId));
    return state.when(
      loading: () => const AgroPage(
        title: 'Cuadrante',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => const AgroPage(
        title: 'Cuadrante',
        child: AgroEmptyState(
          title: 'Cuadrante no disponible',
          message: 'Puede haber sido eliminado o pertenecer a otra cuenta.',
        ),
      ),
      data: (value) => _buildContent(context, ref, value),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    String ownerId,
  ) async {
    final controller = ref.read(sectorDetailControllerProvider(sectorId));
    final field = TextEditingController(
      text: await controller.loadName(ownerId) ?? '',
    );
    if (!context.mounted) return;
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Renombrar cuadrante'),
        content: TextField(
          controller: field,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, field.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    field.dispose();
    if (name == null || !context.mounted) return;
    String message;
    try {
      await controller.rename(ownerId: ownerId, name: name);
      message = 'Nombre actualizado.';
    } on Object catch (error) {
      message = error is StateError && error.message == 'sector_name_required'
          ? 'Escribe un nombre para el cuadrante.'
          : 'No se pudo renombrar el cuadrante: $error';
    }
    if (context.mounted) _notify(context, message);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    String ownerId,
    int number,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('¿Eliminar cuadrante $number?'),
        content: const Text(
          'Dejará de aparecer en el mapa y en nuevos registros. Los registros anteriores se conservan en el historial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(sectorDetailControllerProvider(sectorId)).delete(ownerId);
      if (!context.mounted) return;
      _notify(context, 'Cuadrante $number eliminado.');
      context.pop();
    } on Object catch (error) {
      if (context.mounted) {
        _notify(context, 'No se pudo eliminar el cuadrante: $error');
      }
    }
  }

  static void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SectorDetailUiState state,
  ) {
    switch (state.status) {
      case SectorDetailStatus.signedOut:
        return const AgroPage(
          title: 'Cuadrante',
          child: AgroEmptyState(
            title: 'Sin sesión',
            message: 'Inicia sesión para abrir este cuadrante.',
          ),
        );
      case SectorDetailStatus.notFound:
      case SectorDetailStatus.error:
        return const AgroPage(
          title: 'Cuadrante',
          child: AgroEmptyState(
            title: 'Cuadrante no disponible',
            message: 'Puede haber sido eliminado o pertenecer a otra cuenta.',
          ),
        );
      case SectorDetailStatus.ready:
        final detail = state.detail;
        final summary = state.summary;
        if (detail == null || summary == null) {
          return const AgroPage(
            title: 'Cuadrante',
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.selectedSectorId != detail.id) {
          Future<void>.microtask(
            () => ref
                .read(sectorDetailControllerProvider(sectorId))
                .ensureContextSelected(),
          );
        }
        return AgroPage(
          title: 'Cuadrante ${detail.number}',
          subtitle:
              '${detail.areaSquareMeters.toStringAsFixed(0)} m² · ${summary.statusLabel}',
          actions: [
            IconButton(
              tooltip: 'Abrir mapa de cuadrantes',
              onPressed: () => context.push(AppRoutes.quadrantMap),
              icon: const Icon(LucideIcons.map),
            ),
            PopupMenuButton<String>(
              tooltip: 'Más opciones',
              onSelected: (action) => action == 'rename'
                  ? _rename(context, ref, state.ownerId!)
                  : _delete(context, ref, state.ownerId!, detail.number),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'rename', child: Text('Renombrar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
          child: ListView(
            key: ValueKey('quadrant-${detail.id}-scroll'),
            children: [
              _CropIdentityCard(
                summary: summary,
                onChangeCrop: () =>
                    context.push(AppRoutes.sectorRotation(detail.id)),
                onConfigureSeason: () async {
                  // Seasons are listed for the active quadrant.
                  await ref
                      .read(sectorDetailControllerProvider(detail.id))
                      .ensureContextSelected();
                  if (context.mounted) context.push(AppRoutes.seasons);
                },
                onApiary: summary.isApiary
                    ? () => context.push(AppRoutes.sectorApiary(detail.id))
                    : null,
              ),
              const SizedBox(height: AgroSpacing.lg),
              const AgroSectionHeader(
                title: 'Estado del cuadrante',
                subtitle: 'Últimos datos guardados en el dispositivo.',
              ),
              const SizedBox(height: AgroSpacing.sm),
              AgroAdaptiveGrid(
                columns: 2,
                children: [
                  AgroMetricCard(
                    label: 'Superficie',
                    value: '${summary.areaSquareMeters.toStringAsFixed(0)} m²',
                    icon: LucideIcons.ruler,
                  ),
                  AgroMetricCard(
                    label: 'Humedad del suelo',
                    value: summary.soilMoisturePercent == null
                        ? 'Sin medición'
                        : '${summary.soilMoisturePercent!.toStringAsFixed(0)} %',
                    icon: LucideIcons.droplets,
                  ),
                  AgroMetricCard(
                    label: 'Último riego',
                    value: _date(context, summary.lastIrrigationAt),
                    icon: LucideIcons.droplet,
                  ),
                  AgroMetricCard(
                    label: 'Última medición',
                    value: _date(context, summary.lastSoilAt),
                    icon: LucideIcons.flaskConical,
                  ),
                ],
              ),
              const SizedBox(height: AgroSpacing.lg),
              const AgroSectionHeader(
                title: 'Acciones',
                subtitle:
                    'El contexto de este cuadrante se mantiene en cada flujo.',
              ),
              const SizedBox(height: AgroSpacing.sm),
              // Two columns by three rows keep every action of the quadrant
              // visible at once.
              AgroAdaptiveGrid(
                columns: 2,
                children: [
                  AgroActionTile(
                    icon: LucideIcons.clipboardPlus,
                    label: 'Registrar labor',
                    onTap: () => context.push(
                      AppRoutes.registerFor(sectorId: detail.id),
                    ),
                  ),
                  AgroActionTile(
                    icon: LucideIcons.droplet,
                    label: 'Riego',
                    onTap: () => context.push(
                      AppRoutes.irrigationFor(sectorId: detail.id),
                    ),
                  ),
                  AgroActionTile(
                    icon: LucideIcons.flaskConical,
                    label: 'Suelo',
                    onTap: () =>
                        context.push(AppRoutes.soilFor(sectorId: detail.id)),
                  ),
                  AgroActionTile(
                    icon: LucideIcons.sparkles,
                    label: 'AgroIA',
                    onTap: () => context.push(AppRoutes.agroAi),
                  ),
                  AgroActionTile(
                    icon: LucideIcons.leaf,
                    label: 'Cambiar cultivo',
                    onTap: () =>
                        context.push(AppRoutes.sectorRotation(detail.id)),
                  ),
                  AgroActionTile(
                    icon: LucideIcons.history,
                    label: 'Ver historial',
                    onTap: () =>
                        context.push(AppRoutes.sectorHistory(detail.id)),
                  ),
                ],
              ),
              const SizedBox(height: AgroSpacing.lg),
            ],
          ),
        );
    }
  }

  static String _date(BuildContext context, DateTime? value) => value == null
      ? 'Sin registro'
      : MaterialLocalizations.of(context).formatShortDate(value.toLocal());
}

final class _CropIdentityCard extends StatelessWidget {
  const _CropIdentityCard({
    required this.summary,
    required this.onChangeCrop,
    required this.onConfigureSeason,
    required this.onApiary,
  });

  final SectorCardUiState summary;
  final VoidCallback onChangeCrop;
  final VoidCallback onConfigureSeason;
  final VoidCallback? onApiary;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AgroSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CropPictogram(
                asset: summary.cropIconAsset,
                colorToken: summary.cropColorToken,
                semanticLabel: summary.cropLabel,
              ),
              const SizedBox(width: AgroSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.cropLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AgroSpacing.xxs),
                    Text(
                      summary.seasonLabel ?? 'Sin temporada asignada',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AgroSpacing.xs),
                    Text(summary.statusLabel),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AgroSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onChangeCrop,
                  icon: const Icon(LucideIcons.repeat),
                  label: const Text('Cambiar cultivo'),
                ),
              ),
              const SizedBox(width: AgroSpacing.xs),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onConfigureSeason,
                  icon: const Icon(LucideIcons.calendarRange),
                  label: const Text('Configurar temporada'),
                ),
              ),
            ],
          ),
          if (onApiary case final action?) ...[
            const SizedBox(height: AgroSpacing.xs),
            OutlinedButton.icon(
              onPressed: action,
              icon: const Icon(Icons.hive_outlined),
              label: const Text('Registrar revisión apícola'),
            ),
          ],
        ],
      ),
    ),
  );
}
