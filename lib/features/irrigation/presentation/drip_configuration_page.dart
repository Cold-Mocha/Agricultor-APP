import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/domain/agricultural_context.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/irrigation/data/sector_irrigation_config_repository.dart';
import 'package:agrocampo/features/irrigation/domain/sector_irrigation_config.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/bound_agricultural_context_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class DripConfigurationPage extends ConsumerStatefulWidget {
  const DripConfigurationPage({this.initialSectorId, super.key});
  final String? initialSectorId;

  @override
  ConsumerState<DripConfigurationPage> createState() =>
      _DripConfigurationPageState();
}

final class _DripConfigurationPageState
    extends ConsumerState<DripConfigurationPage> {
  final _plants = TextEditingController();
  final _emitters = TextEditingController();
  final _flow = TextEditingController();
  final _pressure = TextEditingController();
  final _notes = TextEditingController();
  BoundAgriculturalContext? _bound;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bound ??= BoundAgriculturalContext.from(
      ref.read(agriculturalContextControllerProvider),
      sectorId: widget.initialSectorId,
    );
  }

  @override
  void dispose() {
    for (final controller in [_plants, _emitters, _flow, _pressure, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Riego por goteo',
    subtitle: 'Configuración permanente del sector',
    child: ListView(
      children: [
        const AgriculturalContextSelector(requireSector: true),
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
        const SizedBox(height: AgroSpacing.sm),
        FutureBuilder<String>(
          future: _currentLabel(),
          builder: (_, snapshot) =>
              Text(snapshot.data ?? 'Cargando configuración…'),
        ),
        _numberField(_plants, 'Cantidad de plantas'),
        _numberField(_emitters, 'Cantidad total de goteros'),
        _numberField(_flow, 'Caudal total efectivo (ml/min)'),
        _numberField(_pressure, 'Presión (kPa, opcional)'),
        const SizedBox(height: AgroSpacing.sm),
        TextField(
          controller: _notes,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Distribución u observaciones (opcional)',
          ),
        ),
        const SizedBox(height: AgroSpacing.md),
        FilledButton(
          onPressed: _save,
          child: const Text('Guardar nueva versión'),
        ),
        const SizedBox(height: AgroSpacing.sm),
        const Text(
          'Los riegos anteriores conservan la versión de configuración que utilizaron.',
        ),
      ],
    ),
  );

  Widget _numberField(TextEditingController controller, String label) =>
      Padding(
        padding: const EdgeInsets.only(top: AgroSpacing.sm),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
        ),
      );

  Future<String> _currentLabel() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId;
    final sectorId = _bound?.sectorId;
    if (ownerId == null || sectorId == null) return 'Selecciona un sector.';
    final row = await SectorIrrigationConfigRepository(
      ref.read(appDatabaseProvider),
    ).current(ownerId: ownerId, sectorId: sectorId);
    return row == null
        ? 'Sin configuración vigente.'
        : 'Versión ${row.configVersion}: ${row.plantCount} plantas · ${row.emitterCount} goteros · ${row.flowMlMin} ml/min';
  }

  Future<void> _save() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId;
    final sectorId = _bound?.sectorId;
    if (ownerId == null || sectorId == null) return;
    try {
      await SectorIrrigationConfigRepository(ref.read(appDatabaseProvider))
          .saveVersion(
            ownerId: ownerId,
            sectorId: sectorId,
            input: SectorIrrigationConfigInput(
              plantCount: int.tryParse(_plants.text) ?? 0,
              emitterCount: int.tryParse(_emitters.text) ?? 0,
              flowMlMin: int.tryParse(_flow.text) ?? 0,
              pressureKpa: _pressure.text.isEmpty
                  ? null
                  : int.tryParse(_pressure.text),
              distributionNotes: _notes.text,
            ),
          );
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración guardada localmente.')),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa plantas, goteros y caudal con valores positivos.',
          ),
        ),
      );
    }
  }
}
