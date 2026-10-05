import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/crop_cycles/presentation/controllers/crop_cycles_controller.dart';
import 'package:agrocampo/src/modules/crop_cycles/presentation/widgets/initial_crop_sheet.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class AgriculturalSeasonFormPage extends ConsumerStatefulWidget {
  const AgriculturalSeasonFormPage({this.seasonId, super.key});

  final String? seasonId;

  @override
  ConsumerState<AgriculturalSeasonFormPage> createState() =>
      _AgriculturalSeasonFormPageState();
}

final class _AgriculturalSeasonFormPageState
    extends ConsumerState<AgriculturalSeasonFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _notes = TextEditingController();
  DateTime _startsOn = DateTime.now();
  DateTime _endsOn = DateTime.now().add(const Duration(days: 364));
  bool _loaded = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.seasonId == null) return;
    final ownerId = ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) return;
    final row = await ref
        .read(cropsControllerProvider)
        .loadSeason(ownerId: ownerId, id: widget.seasonId!);
    if (row == null || !mounted) return;
    setState(() {
      _notes.text = row.notes ?? '';
      _startsOn = row.startsOn;
      _endsOn = row.endsOn ?? row.startsOn.add(const Duration(days: 364));
    });
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: widget.seasonId == null ? 'Nueva temporada' : 'Editar temporada',
    subtitle: switch (ref.watch(activeSectorNameProvider).value) {
      final name? => 'Configurando $name',
      null => 'La temporada conserva el historial de cultivos y labores.',
    },
    child: Form(
      key: _formKey,
      child: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AgroRadii.large),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AgroSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: _DateTile(
                      label: 'Inicio',
                      value: _startsOn,
                      onTap: () async {
                        final value = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: _startsOn,
                        );
                        if (value == null) return;
                        setState(() {
                          _startsOn = value;
                          if (_endsOn.isBefore(value)) _endsOn = value;
                        });
                      },
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  Expanded(
                    child: _DateTile(
                      label: 'Término',
                      value: _endsOn,
                      onTap: () async {
                        final value = await showDatePicker(
                          context: context,
                          firstDate: _startsOn,
                          lastDate: DateTime(2100),
                          initialDate: _endsOn,
                        );
                        if (value != null) setState(() => _endsOn = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AgroSpacing.md),
          Text(
            'Descripción:',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AgroSpacing.xs),
          TextFormField(
            controller: _notes,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(LucideIcons.save),
            label: Text(_saving ? 'Guardando…' : 'Guardar'),
          ),
        ],
      ),
    ),
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ownerId = ref.read(unlockedOwnerIdProvider);
    final sectorId = ref.read(agriculturalContextControllerProvider).sectorId;
    if (ownerId == null || sectorId == null) return;
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(cropsControllerProvider)
          .saveSeasonByDates(
            ownerId: ownerId,
            sectorId: sectorId,
            id: widget.seasonId,
            startsOn: _startsOn,
            endsOn: _endsOn,
            notes: _notes.text,
          );
      await ref
          .read(agriculturalContextControllerProvider.notifier)
          .selectSeason(id);
      if (widget.seasonId == null && mounted) {
        await _offerCropChange(ownerId: ownerId, sectorId: sectorId, id: id);
      }
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_saveFailure(error))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// A new season may bring a new crop: offers to set it right away.
  Future<void> _offerCropChange({
    required String ownerId,
    required String sectorId,
    required String id,
  }) async {
    final status = AgriculturalSeason.statusFor(
      startsOn: _startsOn,
      endsOn: _endsOn,
      today: DateTime.now(),
    );
    if (status == AgriculturalSeasonStatus.closed) return;
    final sector = await ref
        .read(sectorDetailFacadeProvider(sectorId))
        .loadSector(ownerId);
    if (!mounted || !isRotationAvailableForSector(sector?.kind)) return;
    final wantsChange = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cambiar también el cultivo?'),
        content: Text(
          status == AgriculturalSeasonStatus.active
              ? 'Puedes elegir otro cultivo para esta temporada. Reemplaza al actual desde hoy.'
              : 'Puedes elegir el cultivo de esta temporada. Empieza junto con ella.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cambiar cultivo'),
          ),
        ],
      ),
    );
    if (wantsChange != true || !mounted) return;
    final crop = await pickInitialCrop(
      context,
      ref,
      ownerId: ownerId,
      title: '¿Qué cultivas en esta temporada?',
      message: status == AgriculturalSeasonStatus.active
          ? 'Queda como cultivo vigente desde hoy.'
          : 'Queda como cultivo desde el inicio de la temporada.',
    );
    if (crop == null || !mounted) return;
    try {
      await ref
          .read(cropsControllerProvider)
          .assignCropForSeason(
            ownerId: ownerId,
            sectorId: sectorId,
            agriculturalSeasonId: id,
            crop: crop,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${crop.label} queda en esta temporada.')),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La temporada se guardó, pero no se pudo cambiar el cultivo.',
          ),
        ),
      );
    }
  }
}

final class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(LucideIcons.calendarDays),
    title: Text(label),
    subtitle: Text('${value.day}/${value.month}/${value.year}'),
    onTap: onTap,
  );
}

String _saveFailure(Object error) {
  final reason = switch (error) {
    StateError(:final message) => message,
    ArgumentError(:final message) => '$message',
    _ => '',
  };
  return switch (reason) {
    'active_season_exists' =>
      'Ya hay otra temporada activa en este cuadrante para hoy.',
    'season_name_duplicate' => 'Ya existe una temporada con esas fechas.',
    'season_transition_invalid' =>
      'Una temporada cerrada no se puede volver a abrir.',
    'season_range_invalid' => 'El término debe ser posterior al inicio.',
    _ => 'No se pudo guardar la temporada.',
  };
}
