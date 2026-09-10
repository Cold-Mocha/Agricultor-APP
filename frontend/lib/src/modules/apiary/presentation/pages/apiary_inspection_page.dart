import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/apiary/presentation/controllers/apiary_inspection_controller.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class ApiaryInspectionPage extends ConsumerStatefulWidget {
  const ApiaryInspectionPage({this.sectorId, super.key});
  final String? sectorId;

  @override
  ConsumerState<ApiaryInspectionPage> createState() =>
      _ApiaryInspectionPageState();
}

final class _ApiaryInspectionPageState
    extends ConsumerState<ApiaryInspectionPage> {
  final _beekeeper = TextEditingController();
  final _hives = TextEditingController();
  final _queen = TextEditingController();
  final _brood = TextEditingController();
  final _feeding = TextEditingController();
  final _health = TextEditingController();
  final _pests = TextEditingController();
  final _observations = TextEditingController();
  ApiaryTaskType _task = ApiaryTaskType.inspection;
  bool _superInstalled = false;
  BoundAgriculturalContext? _bound;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bound ??= BoundAgriculturalContext.from(
      ref.read(agriculturalContextControllerProvider),
      sectorId: widget.sectorId,
    );
  }

  @override
  void dispose() {
    for (final controller in [
      _beekeeper,
      _hives,
      _queen,
      _brood,
      _feeding,
      _health,
      _pests,
      _observations,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AgroPage(
      title: 'Revisión apícola',
      subtitle: 'El apicultor es un dato descriptivo, no una cuenta',
      child: ListView(
        children: [
        if (widget.sectorId != null) ...[
          BoundAgriculturalContextCard(
            bound: _bound!,
            changed: _bound!.differsFrom(
              ref.watch(agriculturalContextControllerProvider),
            ),
            onRebind: () => setState(
              () => _bound = BoundAgriculturalContext.from(
                ref.read(agriculturalContextControllerProvider),
              ),
            ),
          ),
        ],
        DropdownButtonFormField<ApiaryTaskType>(
          initialValue: _task,
          decoration: const InputDecoration(labelText: 'Tipo de tarea'),
          items: [
            for (final value in ApiaryTaskType.values)
              DropdownMenuItem(value: value, child: Text(_label(value))),
          ],
          onChanged: (value) => setState(() => _task = value ?? _task),
        ),
        _field(_beekeeper, 'Apicultor responsable'),
        _field(_hives, 'Cantidad de colmenas', number: true),
        _field(_queen, 'Estado de la reina'),
        _field(_brood, 'Postura'),
        _field(_feeding, 'Alimentación'),
        _field(_health, 'Enfermedades / sanidad'),
        _field(_pests, 'Plagas'),
        SwitchListTile(
          value: _superInstalled,
          onChanged: (value) => setState(() => _superInstalled = value),
          title: const Text('Alza instalada'),
        ),
        _field(_observations, 'Observaciones'),
        if (widget.sectorId != null)
          OutlinedButton.icon(
            onPressed: () => context.push(
              AppRoutes.photoFor(sectorId: _bound?.sectorId ?? widget.sectorId),
            ),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Adjuntar fotografía'),
          ),
        const SizedBox(height: AgroSpacing.md),
        FilledButton(onPressed: _save, child: const Text('Guardar revisión')),
      ],
    ),
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) => Padding(
    padding: const EdgeInsets.only(top: AgroSpacing.sm),
    child: TextField(
      key: ValueKey('apiary-$label'),
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
    ),
  );

  Future<void> _save() async {
    final sectorId = _bound?.sectorId ?? widget.sectorId;
    if (sectorId == null) return;
    if (_bound?.category != ProductiveCategory.apiary) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una unidad apícola para esta operación.'),
        ),
      );
      return;
    }
    final saved = await ref
        .read(apiaryInspectionControllerProvider)
        .save(
          sectorId: sectorId,
          input: ApiaryInspectionInput(
            taskType: _task,
            beekeeperName: _beekeeper.text,
            hiveCount: int.tryParse(_hives.text) ?? 0,
            queenStatus: _queen.text,
            broodStatus: _brood.text,
            feedingStatus: _feeding.text,
            healthNotes: _health.text,
            pestNotes: _pests.text,
            superInstalled: _superInstalled,
            inspectedAt: DateTime.now(),
            observations: _observations.text,
          ),
        );
    if (mounted && saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revisión guardada en este dispositivo.')),
      );
    }
  }

  static String _label(ApiaryTaskType type) => switch (type) {
    ApiaryTaskType.inspection => 'Inspección',
    ApiaryTaskType.feeding => 'Alimentación',
    ApiaryTaskType.health => 'Sanidad',
    ApiaryTaskType.harvest => 'Cosecha',
    ApiaryTaskType.superPlacement => 'Colocación de alza',
    ApiaryTaskType.other => 'Otra',
  };
}
