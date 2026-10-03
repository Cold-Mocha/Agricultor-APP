import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/crop_cycles/presentation/controllers/crop_cycles_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class RotationPage extends ConsumerStatefulWidget {
  const RotationPage({required this.sectorId, super.key});

  final String sectorId;

  @override
  ConsumerState<RotationPage> createState() => _RotationPageState();
}

final class _RotationPageState extends ConsumerState<RotationPage> {
  String? _loadedOwnerId;
  Future<Sector?>? _sectorFuture;

  String get sectorId => widget.sectorId;

  Future<Sector?> _loadSector(String ownerId) {
    if (_loadedOwnerId != ownerId || _sectorFuture == null) {
      _loadedOwnerId = ownerId;
      _sectorFuture = ref
          .read(sectorDetailFacadeProvider(sectorId))
          .loadSector(ownerId);
    }
    return _sectorFuture!;
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final controller = ref.watch(cropsControllerProvider);
    if (ownerId == null) {
      return const AgroPage(
        title: 'Cultivos del sector',
        subtitle: 'Planificar no cambia el cultivo vigente antes de la fecha.',
        child: AgroEmptyState(
          title: 'Sin sesión',
          message: 'Inicia sesión para administrar cultivos.',
        ),
      );
    }
    final sectorFuture = _loadSector(ownerId);
    return FutureBuilder<Sector?>(
      future: sectorFuture,
      builder: (context, sectorSnapshot) {
        final sector = sectorSnapshot.data;
        final available = isRotationAvailableForSector(sector?.kind);
        return AgroPage(
          title: 'Cultivos del sector',
          subtitle:
              'Planificar no cambia el cultivo vigente antes de la fecha.',
          actions: available
              ? [
                  IconButton(
                    tooltip: 'Intercambiar cultivos',
                    onPressed: () => _exchange(context, ref, ownerId),
                    icon: const Icon(LucideIcons.arrowLeftRight),
                  ),
                  IconButton(
                    tooltip: 'Asignar cultivo',
                    onPressed: () => _assign(context, ref, ownerId),
                    icon: const Icon(LucideIcons.sprout),
                  ),
                  IconButton(
                    tooltip: 'Planificar cultivo',
                    onPressed: () => _plan(context, ref, ownerId),
                    icon: const Icon(LucideIcons.plus),
                  ),
                ]
              : const [],
          child: sectorSnapshot.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : sector == null
              ? const AgroEmptyState(
                  title: 'Sector no disponible',
                  message: 'No se pudo cargar el contexto del sector.',
                )
              : !available
              ? AgroEmptyState(
                  title: 'Rotación no disponible',
                  message:
                      'La rotación de cultivos sólo está disponible en sectores vegetales. Este es un ${rotationContextLabel(sector.kind).toLowerCase()}.',
                )
              : StreamBuilder<List<SectorCropAssignment>>(
                  stream: controller.watchAssignments(
                    ownerId: ownerId,
                    sectorId: sectorId,
                  ),
                  builder: (context, snapshot) {
                    final assignments = snapshot.data ?? const [];
                    final contextCard = Card(
                      child: ListTile(
                        leading: const Icon(LucideIcons.leaf),
                        title: Text('Contexto: ${sector.name}'),
                        subtitle: Text(
                          '${rotationContextLabel(sector.kind)} · fechas efectivas conservan el historial',
                        ),
                      ),
                    );
                    if (assignments.isEmpty) {
                      return ListView(
                        children: [
                          contextCard,
                          AgroEmptyState(
                            title: 'Sin cultivos asignados',
                            message: 'Asigna el cultivo vigente del sector. Necesitas una temporada activa en este cuadrante.',
                            action: Wrap(
                              spacing: AgroSpacing.sm,
                              runSpacing: AgroSpacing.sm,
                              alignment: WrapAlignment.center,
                              children: [
                                FilledButton.icon(
                                  onPressed: () =>
                                      _assign(context, ref, ownerId),
                                  icon: const Icon(LucideIcons.sprout),
                                  label: const Text('Asignar cultivo'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.push(AppRoutes.seasons),
                                  icon: const Icon(LucideIcons.calendarDays),
                                  label: const Text('Administrar temporadas'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView(
                      children: [
                        contextCard,
                        for (final assignment in assignments)
                          Card(
                            child: ListTile(
                              leading: Icon(
                                assignment.status ==
                                        SectorCropAssignmentStatus.active
                                    ? LucideIcons.leaf
                                    : LucideIcons.calendar,
                              ),
                              title: Text(assignment.crop.label),
                              subtitle: Text(
                                '${_status(assignment)} · desde ${_date(assignment.effectiveFrom)}${assignment.effectiveTo == null ? '' : ' hasta ${_date(assignment.effectiveTo!)}'} · ${assignment.syncState == 'synced' ? 'Sincronizado' : 'Local'}',
                              ),
                              trailing: switch (assignment.status) {
                                SectorCropAssignmentStatus.planned ||
                                SectorCropAssignmentStatus.active =>
                                  PopupMenuButton<String>(
                                    onSelected: (action) => _assignmentAction(
                                      context,
                                      ref,
                                      ownerId,
                                      assignment,
                                      action,
                                    ),
                                    itemBuilder: (_) => [
                                      if (isRotationActivationDue(assignment))
                                        const PopupMenuItem(
                                          value: 'activate',
                                          child: Text(
                                            'Activar en fecha planificada',
                                          ),
                                        ),
                                      if (assignment.status ==
                                          SectorCropAssignmentStatus.planned)
                                        const PopupMenuItem(
                                          value: 'cancel',
                                          child: Text('Cancelar planificación'),
                                        ),
                                      if (assignment.status ==
                                          SectorCropAssignmentStatus.active)
                                        const PopupMenuItem(
                                          value: 'end',
                                          child: Text('Quitar cultivo'),
                                        ),
                                    ],
                                  ),
                                _ => null,
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _assign(
    BuildContext context,
    WidgetRef ref,
    String ownerId,
  ) async {
    if (!await _ensureCropContext(context, ref, ownerId)) return;
    final controller = ref.read(cropsControllerProvider);
    final options = await controller.planOptions(
      ownerId: ownerId,
      sectorId: sectorId,
    );
    if (!context.mounted) return;
    final season = options?.season;
    if (season == null) {
      _notify(
        context,
        'Primero crea o activa una temporada en este cuadrante.',
        action: SnackBarAction(
          label: 'Temporadas',
          onPressed: () => context.push(AppRoutes.seasons),
        ),
      );
      return;
    }
    final crops = options!.crops;
    if (crops.isEmpty) {
      _notify(context, 'El catálogo no tiene cultivos disponibles.');
      return;
    }
    final today = DateTime.now();
    if (today.isBefore(season.startsOn)) {
      _notify(
        context,
        'La temporada activa empieza el ${_date(season.startsOn)}. Planifica el cultivo para esa fecha.',
      );
      return;
    }
    CropRef selected = crops.first;
    var date = today;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Asignar cultivo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<CropRef>(
                initialValue: selected,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Cultivo'),
                items: [
                  for (final crop in crops)
                    DropdownMenuItem(value: crop, child: Text(crop.label)),
                ],
                onChanged: (value) => selected = value!,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Vigente desde'),
                subtitle: Text(_date(date)),
                onTap: () async {
                  final value = await showDatePicker(
                    context: dialogContext,
                    firstDate: season.startsOn,
                    lastDate: today,
                    initialDate: date,
                  );
                  if (value != null) setDialogState(() => date = value);
                },
              ),
              Text(
                'Temporada: ${season.name}. Si el sector ya tiene un cultivo vigente, termina en esta fecha.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true) return;
    try {
      await controller.assign(
        ownerId: ownerId,
        sectorId: sectorId,
        agriculturalSeasonId: season.id,
        crop: selected,
        effectiveFrom: date,
      );
      if (context.mounted) {
        _notify(
          context,
          '${selected.label} asignado. Ya puedes registrar riego y labores.',
        );
      }
    } on Object catch (error) {
      if (context.mounted) _notify(context, _assignFailure(error));
    }
  }

  Future<void> _assignmentAction(
    BuildContext context,
    WidgetRef ref,
    String ownerId,
    SectorCropAssignment assignment,
    String action,
  ) async {
    final controller = ref.read(cropsControllerProvider);
    if (action == 'end') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('¿Quitar ${assignment.crop.label}?'),
          content: const Text(
            'El cultivo termina hoy. Sus labores y riegos se conservan en el historial.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Quitar'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    try {
      switch (action) {
        case 'activate':
          await controller.activate(
            ownerId: ownerId,
            assignmentId: assignment.id,
            effectiveAt: assignment.effectiveFrom,
          );
        case 'cancel':
          await controller.cancel(
            ownerId: ownerId,
            assignmentId: assignment.id,
          );
        case 'end':
          await controller.end(
            ownerId: ownerId,
            assignmentId: assignment.id,
            effectiveAt: DateTime.now(),
          );
      }
      if (!context.mounted) return;
      _notify(context, switch (action) {
        'activate' => '${assignment.crop.label} ahora es el cultivo vigente.',
        'cancel' => 'Planificación cancelada.',
        _ => '${assignment.crop.label} quitado del sector.',
      });
    } on Object catch (error) {
      if (context.mounted) _notify(context, _assignFailure(error));
    }
  }

  static String _assignFailure(Object error) => switch (error) {
    StateError(message: 'rotation_overlap') =>
      'Ya hay un cultivo planificado en esas fechas. Cancélalo o actívalo.',
    StateError(message: 'assignment_outside_season') =>
      'La fecha queda fuera de la temporada activa.',
    StateError(message: 'season_closed' || 'assignment_season_not_active') =>
      'La temporada está cerrada. Activa una temporada en este cuadrante.',
    StateError(message: 'operation_requires_crop') =>
      'Sólo los sectores vegetales pueden tener cultivo.',
    StateError(message: 'assignment_end_before_start') =>
      'El cultivo empieza en una fecha futura. Cancela su planificación.',
    _ => 'No se pudo actualizar el cultivo: $error',
  };

  static void _notify(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  Future<void> _plan(
    BuildContext context,
    WidgetRef ref,
    String ownerId,
  ) async {
    if (!await _ensureCropContext(context, ref, ownerId)) return;
    final controller = ref.read(cropsControllerProvider);
    final options = await controller.planOptions(
      ownerId: ownerId,
      sectorId: sectorId,
    );
    final season = options?.season;
    if (season == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Primero activa una temporada.')),
        );
      }
      return;
    }
    final crops = options!.crops;
    if (!context.mounted || crops.isEmpty) return;
    CropRef selected = crops.first;
    var date = DateTime.now().add(const Duration(days: 1));
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Planificar cultivo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<CropRef>(
                initialValue: selected,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Cultivo'),
                items: [
                  for (final crop in crops)
                    DropdownMenuItem(value: crop, child: Text(crop.label)),
                ],
                onChanged: (value) => selected = value!,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha efectiva'),
                subtitle: Text(_date(date)),
                onTap: () async {
                  final value = await showDatePicker(
                    context: dialogContext,
                    firstDate: season.startsOn,
                    lastDate: season.endsOn ?? DateTime(2100),
                    initialDate: date.isBefore(season.startsOn)
                        ? season.startsOn
                        : date,
                  );
                  if (value != null) setDialogState(() => date = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Planificar'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true) {
      await controller.plan(
        ownerId: ownerId,
        sectorId: sectorId,
        agriculturalSeasonId: season.id,
        crop: selected,
        effectiveFrom: date,
      );
    }
  }

  Future<void> _exchange(
    BuildContext context,
    WidgetRef ref,
    String ownerId,
  ) async {
    if (!await _ensureCropContext(context, ref, ownerId)) return;
    final controller = ref.read(cropsControllerProvider);
    final alternatives = await controller.exchangeOptions(
      ownerId: ownerId,
      sectorId: sectorId,
    );
    if (!context.mounted || alternatives.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay otro sector disponible.')),
        );
      }
      return;
    }
    var selected = alternatives.first;
    var date = DateTime.now();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Intercambiar cultivos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                initialValue: selected.id,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Otro sector'),
                items: [
                  for (final sector in alternatives)
                    DropdownMenuItem(
                      value: sector.id,
                      child: Text(sector.name),
                    ),
                ],
                onChanged: (value) => selected = alternatives.singleWhere(
                  (sector) => sector.id == value,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha efectiva'),
                subtitle: Text(_date(date)),
                onTap: () async {
                  final value = await showDatePicker(
                    context: dialogContext,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    initialDate: date,
                  );
                  if (value != null) setDialogState(() => date = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Intercambiar'),
            ),
          ],
        ),
      ),
    );
    if (accepted == true) {
      await controller.exchange(
        ownerId: ownerId,
        firstSectorId: sectorId,
        secondSectorId: selected.id,
        effectiveAt: date,
      );
    }
  }

  Future<bool> _ensureCropContext(
    BuildContext context,
    WidgetRef ref,
    String ownerId,
  ) async {
    final sector = await ref
        .read(sectorDetailFacadeProvider(sectorId))
        .watchSector(ownerId)
        .first;
    if (sector != null &&
        ProductiveCategory.fromCode(sector.kind) == ProductiveCategory.crop) {
      return true;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La rotación sólo está disponible en sectores vegetales.',
          ),
        ),
      );
    }
    return false;
  }

  static String _status(SectorCropAssignment assignment) =>
      switch (assignment.status) {
        SectorCropAssignmentStatus.active => 'Vigente',
        SectorCropAssignmentStatus.planned =>
          'Planificado para ${_date(assignment.effectiveFrom)}',
        SectorCropAssignmentStatus.ended => 'Finalizado',
        SectorCropAssignmentStatus.cancelled => 'Cancelado',
      };

  static String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
