import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/apiary/data/apiary_repository.dart';
import 'package:agrocampo/features/apiary/domain/apiary_inspection_input.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
    ),
  );

  Future<void> _save() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId;
    final database = ref.read(appDatabaseProvider);
    if (ownerId == null) return;
    final sectorId =
        widget.sectorId ??
        ref.read(agriculturalContextControllerProvider).sectorId;
    if (sectorId == null) return;
    await ApiaryRepository(database).save(
      ownerId: ownerId,
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
    if (mounted) {
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
