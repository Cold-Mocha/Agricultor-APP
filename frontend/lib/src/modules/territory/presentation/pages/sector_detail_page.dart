import 'dart:async';

import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/history/history_ui.dart';
import 'package:agrocampo/src/modules/territory/presentation/controllers/territory_controllers.dart';
import 'package:agrocampo/src/modules/weather/weather_ui.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_action_tile.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_metric_card.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_section_header.dart';
import 'package:agrocampo/src/shared/design_system/components/crop_pictogram.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
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
                uniformHeight: true,
                children: [
                  AgroMetricCard(
                    label: 'Superficie',
                    value: '${summary.areaSquareMeters.toStringAsFixed(0)} m²',
                    icon: LucideIcons.ruler,
                  ),
                  AgroMetricCard(
                    label: 'Última labor',
                    value: _date(context, summary.lastLaborAt),
                    icon: LucideIcons.clipboardCheck,
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
              _QuadrantClimate(
                ownerId: state.ownerId!,
                sectorId: detail.id,
                label: 'Cuadrante ${detail.number}',
                summary: summary,
              ),
              const SizedBox(height: AgroSpacing.lg),
              const AgroSectionHeader(
                title: 'Acciones',
                subtitle:
                    'El contexto de este cuadrante se mantiene en cada flujo.',
              ),
              const SizedBox(height: AgroSpacing.sm),
              // Riego and Suelo are grouped on a shared surface above the
              // full-width Registrar labor action.
              Container(
                padding: const EdgeInsets.all(AgroSpacing.xs),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AgroRadii.medium),
                ),
                child: AgroAdaptiveGrid(
                  columns: 2,
                  uniformHeight: true,
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(height: AgroSpacing.xs),
              AgroActionTile(
                icon: LucideIcons.clipboardPlus,
                label: 'Registrar labor',
                onTap: () =>
                    context.push(AppRoutes.registerFor(sectorId: detail.id)),
              ),
              const SizedBox(height: AgroSpacing.lg),
              const AgroSectionHeader(
                title: 'Historial',
                subtitle: 'Actividad reciente de este cuadrante.',
              ),
              const SizedBox(height: AgroSpacing.sm),
              _SectorHistorySection(
                ownerId: state.ownerId!,
                sectorId: detail.id,
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
  // No surrounding card: the crop and its two actions sit on the page.
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AgroSpacing.xs),
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
              apiary: summary.isApiary,
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
            icon: const Icon(CropPictogram.apiaryIcon),
            label: const Text('Registrar revisión apícola'),
          ),
        ],
      ],
    ),
  );
}

/// Weather of the quadrant next to its last soil reading, in the same
/// two-by-two metric layout as the quadrant status.
final class _QuadrantClimate extends ConsumerStatefulWidget {
  const _QuadrantClimate({
    required this.ownerId,
    required this.sectorId,
    required this.label,
    required this.summary,
  });

  final String ownerId;
  final String sectorId;
  final String label;
  final SectorCardUiState summary;

  @override
  ConsumerState<_QuadrantClimate> createState() => _QuadrantClimateState();
}

final class _QuadrantClimateState extends ConsumerState<_QuadrantClimate> {
  /// Weather is refreshed hourly while the quadrant stays open.
  static const _autoRefresh = Duration(hours: 1);

  late Future<WeatherLoadResult> _weather = _load();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_autoRefresh, (_) => _reload());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<WeatherLoadResult> _load({bool forceRefresh = false}) => ref
      .read(weatherControllerProvider)
      .load(
        ownerId: widget.ownerId,
        locality: widget.label,
        sectorId: widget.sectorId,
        forceRefresh: forceRefresh,
      );

  void _reload() => setState(() => _weather = _load(forceRefresh: true));

  @override
  void didUpdateWidget(covariant _QuadrantClimate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectorId != widget.sectorId) _weather = _load();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<WeatherLoadResult>(
    future: _weather,
    builder: (context, snapshot) {
      final weather = switch (snapshot.data) {
        WeatherFresh(:final snapshot) => snapshot,
        WeatherStale(:final snapshot) => snapshot,
        _ => null,
      };
      final loading = snapshot.connectionState != ConnectionState.done;
      final missing = loading ? 'Cargando…' : 'Sin datos';
      final soilMoisture = widget.summary.soilMoisturePercent;
      final soilTemperature = widget.summary.soilTemperatureC;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: AgroSectionHeader(
                  title: 'Clima en el cuadrante',
                  subtitle: 'Se actualiza cada hora.',
                ),
              ),
              IconButton(
                tooltip: 'Actualizar clima',
                onPressed: loading ? null : _reload,
                icon: loading
                    ? const SizedBox.square(
                        dimension: AgroSizes.iconStandard,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.refreshCw),
              ),
            ],
          ),
          const SizedBox(height: AgroSpacing.sm),
          AgroAdaptiveGrid(
            columns: 2,
            uniformHeight: true,
            children: [
              AgroMetricCard(
                label: 'Clima',
                value: weather == null
                    ? missing
                    : '${weather.temperatureC.round()} °C',
                supportingText: weather?.summary,
                icon: LucideIcons.cloudSun,
              ),
              AgroMetricCard(
                label: 'Humedad',
                value: weather == null
                    ? missing
                    : '${weather.humidityPercent} %',
                icon: LucideIcons.droplets,
              ),
              AgroMetricCard(
                label: 'Humedad del suelo',
                value: soilMoisture == null
                    ? 'Sin medición'
                    : '${soilMoisture.toStringAsFixed(0)} %',
                icon: LucideIcons.sprout,
              ),
              AgroMetricCard(
                label: 'Temp. del suelo',
                value: soilTemperature == null
                    ? 'Sin medición'
                    : '${soilTemperature.toStringAsFixed(1)} °C',
                icon: LucideIcons.thermometer,
              ),
            ],
          ),
        ],
      );
    },
  );
}

/// Shows this quadrant's history inline instead of linking out to a
/// separate page.
final class _SectorHistorySection extends ConsumerWidget {
  const _SectorHistorySection({required this.ownerId, required this.sectorId});

  final String ownerId;
  final String sectorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      FutureBuilder<List<HistoryEvent>>(
        future: ref
            .watch(historyControllerProvider)
            .list(HistoryFilter(ownerId: ownerId, sectorId: sectorId)),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data ?? const <HistoryEvent>[];
          if (events.isEmpty) {
            return const AgroEmptyState(
              title: 'Sin registros',
              message: 'Las actividades de este cuadrante aparecerán aquí.',
            );
          }
          return Column(
            children: [
              for (final event in events)
                Padding(
                  padding: const EdgeInsets.only(bottom: AgroSpacing.xs),
                  child: Card(
                    child: ListTile(
                      leading: Icon(switch (event.type) {
                        HistoryEventType.labor => LucideIcons.wheat,
                        HistoryEventType.cropAssignment => LucideIcons.leaf,
                        HistoryEventType.soil => LucideIcons.flaskConical,
                      }),
                      title: Text(event.title),
                      subtitle: Text(
                        [
                          if (event.cropLabel != null) event.cropLabel!,
                          if (event.detail != null && event.detail!.isNotEmpty)
                            event.detail!,
                          MaterialLocalizations.of(context)
                              .formatShortDate(event.occurredAt.toLocal()),
                        ].join(' · '),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
}
