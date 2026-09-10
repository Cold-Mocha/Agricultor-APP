import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/crop_cycles/presentation/controllers/crop_cycles_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class RotationPage extends ConsumerWidget {
  const RotationPage({required this.sectorId, super.key});

  final String sectorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final controller = ref.watch(cropsControllerProvider);
    return AgroPage(
      title: 'Cultivos del sector',
      subtitle: 'Planificar no cambia el cultivo vigente antes de la fecha.',
      actions: [
        IconButton(
          tooltip: 'Intercambiar cultivos',
          onPressed: ownerId == null
              ? null
              : () => _exchange(context, ref, ownerId),
          icon: const Icon(Icons.swap_horiz),
        ),
        IconButton(
          tooltip: 'Planificar cultivo',
          onPressed: ownerId == null
              ? null
              : () => _plan(context, ref, ownerId),
          icon: const Icon(Icons.add),
        ),
      ],
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin sesión',
              message: 'Inicia sesión para administrar cultivos.',
            )
          : FutureBuilder<void>(
              future: controller.ensureCatalog(),
              builder: (_, _) => StreamBuilder<List<SectorCropAssignment>>(
                stream: controller.watchAssignments(
                  ownerId: ownerId,
                  sectorId: sectorId,
                ),
                builder: (context, snapshot) {
                  final assignments = snapshot.data ?? const [];
                  if (assignments.isEmpty) {
                    return AgroEmptyState(
                      title: 'Sin cultivos asignados',
                      message: 'Crea o activa una temporada y planifica el primer cultivo.',
                      action: FilledButton.icon(
                        onPressed: () => context.push(AppRoutes.seasons),
                        icon: const Icon(Icons.calendar_month_outlined),
                        label: const Text('Administrar temporadas'),
                      ),
                    );
                  }
                  return ListView(
                    children: [
                      for (final assignment in assignments)
                        Card(
                          child: ListTile(
                            leading: Icon(
                              assignment.status ==
                                      SectorCropAssignmentStatus.active
                                  ? Icons.eco
                                  : Icons.event_outlined,
                            ),
                            title: Text(assignment.crop.label),
                            subtitle: Text(
                              '${_status(assignment)} · desde ${_date(assignment.effectiveFrom)}${assignment.effectiveTo == null ? '' : ' hasta ${_date(assignment.effectiveTo!)}'} · ${assignment.syncState == 'synced' ? 'Sincronizado' : 'Local'}',
                            ),
                            trailing:
                                assignment.status ==
                                    SectorCropAssignmentStatus.planned
                                ? PopupMenuButton<String>(
                                    onSelected: (action) async {
                                      if (action == 'activate') {
                                        await controller.activate(
                                          ownerId: ownerId,
                                          assignmentId: assignment.id,
                                          effectiveAt: assignment.effectiveFrom,
                                        );
                                      } else {
                                        await controller.cancel(
                                          ownerId: ownerId,
                                          assignmentId: assignment.id,
                                        );
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'activate',
                                        child: Text(
                                          'Activar en fecha planificada',
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'cancel',
                                        child: Text('Cancelar planificación'),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Future<void> _plan(
    BuildContext context,
    WidgetRef ref,
    String ownerId,
  ) async {
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
