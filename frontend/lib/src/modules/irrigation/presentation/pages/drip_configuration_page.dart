import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/irrigation/presentation/controllers/irrigation_controller.dart';
import 'package:agrocampo/src/modules/irrigation/presentation/formatters/irrigation_labels.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
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
  IrrigationType _type = IrrigationType.drip;
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
        DropdownButtonFormField<IrrigationType>(
          key: const ValueKey('irrigation-type'),
          isExpanded: true,
          initialValue: _type,
          decoration: const InputDecoration(labelText: 'Tipo de riego'),
          items: [
            for (final value in IrrigationType.values)
              DropdownMenuItem(value: value, child: Text(value.label)),
          ],
          onChanged: (value) => setState(() => _type = value ?? _type),
        ),
        const SizedBox(height: AgroSpacing.md),
        if (_type != IrrigationType.drip) ...[
          const Text(
            'La configuración de goteo solo aplica al riego por goteo. Selecciona "Goteo" para continuar.',
          ),
        ] else ...[
          const _StepHeader(step: 'Paso 1', title: 'Goteros del sector'),
          const SizedBox(height: AgroSpacing.sm),
          _numberField(_plants, 'Cantidad de plantas'),
          _numberField(_emitters, 'Cantidad total de goteros'),
          const SizedBox(height: AgroSpacing.md),
          const _StepHeader(step: 'Paso 2', title: 'Caudal y presión'),
          const SizedBox(height: AgroSpacing.sm),
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

  Future<void> _save() async {
    final sectorId = _bound?.sectorId;
    if (sectorId == null) {
      _notify('Selecciona un sector antes de guardar la configuración.');
      return;
    }
    try {
      final saved = await ref
          .read(irrigationFormControllerProvider)
          .saveConfiguration(
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
      if (!saved) {
        _notify(
          'Inicia sesión o desbloquea la app para guardar la configuración.',
        );
        return;
      }
      setState(() {});
      _notify('Configuración guardada.');
    } on Object {
      if (!mounted) return;
      _notify('Completa plantas, goteros y caudal con valores positivos.');
    }
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

final class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.title});

  final String step;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AgroSpacing.sm,
          vertical: AgroSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AgroRadii.small),
        ),
        child: Text(
          step,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(width: AgroSpacing.sm),
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    ],
  );
}
