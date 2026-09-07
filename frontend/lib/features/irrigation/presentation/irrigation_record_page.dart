import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/agro_status_banner.dart';
import 'package:agrocampo/shared/presentation/components/bound_agricultural_context_card.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class IrrigationRecordPage extends ConsumerStatefulWidget {
  const IrrigationRecordPage({this.initialSectorId, super.key});
  final String? initialSectorId;

  @override
  ConsumerState<IrrigationRecordPage> createState() =>
      _IrrigationRecordPageState();
}

final class _IrrigationRecordPageState
    extends ConsumerState<IrrigationRecordPage> {
  IrrigationType _type = IrrigationType.drip;
  SoilType _soil = SoilType.unknown;
  final _duration = TextEditingController();
  final _flow = TextEditingController();
  String _calculationMessage =
      'Regla agronómica no disponible para este cultivo y tipo de suelo.';
  BoundAgriculturalContext? _bound;
  IrrigationCalculationUiState? _preview;

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
    _duration.dispose();
    _flow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Riego',
    subtitle: 'Registro básico disponible sin conexión',
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
        OutlinedButton.icon(
          onPressed: () => context.push(
            AppRoutes.irrigationConfigurationFor(sectorId: _bound?.sectorId),
          ),
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Configurar goteo del sector'),
        ),
        const SizedBox(height: AgroSpacing.sm),
        DropdownButtonFormField(
          key: const ValueKey('irrigation-type'),
          isExpanded: true,
          initialValue: _type,
          decoration: const InputDecoration(labelText: 'Tipo de riego'),
          items: [
            for (final value in IrrigationType.values)
              DropdownMenuItem(value: value, child: Text(value.name)),
          ],
          onChanged: (value) => setState(() => _type = value ?? _type),
        ),
        const SizedBox(height: AgroSpacing.sm),
        DropdownButtonFormField(
          isExpanded: true,
          initialValue: _soil,
          decoration: const InputDecoration(labelText: 'Tipo de suelo'),
          items: [
            for (final value in SoilType.values)
              DropdownMenuItem(value: value, child: Text(value.name)),
          ],
          onChanged: (value) => setState(() => _soil = value ?? _soil),
        ),
        const SizedBox(height: AgroSpacing.sm),
        TextField(
          controller: _duration,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Duración (minutos)'),
        ),
        const SizedBox(height: AgroSpacing.sm),
        if (_type != IrrigationType.drip) ...[
          TextField(
            controller: _flow,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Caudal (litros/hora, opcional)',
            ),
          ),
          const SizedBox(height: AgroSpacing.md),
        ],
        const SizedBox(height: AgroSpacing.sm),
        AgroStatusBanner(
          message: _calculationMessage,
          status: AgroStatus.warning,
        ),
        TextButton(
          onPressed: _calculate,
          child: const Text('Calcular de forma determinística'),
        ),
        const Text(
          'El clima es auxiliar; si no está disponible, el registro offline sigue funcionando.',
        ),
        const SizedBox(height: AgroSpacing.md),
        FilledButton(onPressed: _save, child: const Text('Guardar riego')),
      ],
    ),
  );

  IrrigationFormInput _input() {
    return IrrigationFormInput(
      sectorId: _bound?.sectorId,
      type: _type,
      soilType: _soil,
      duration: _duration.text,
      flow: _flow.text,
    );
  }

  Future<void> _calculate() async {
    final input = _input();
    final calculation = await ref
        .read(irrigationFormControllerProvider)
        .calculate(input);
    if (!mounted || calculation == null) return;
    setState(() {
      _calculationMessage = calculation.message;
      if (_type == IrrigationType.drip) _preview = calculation;
    });
  }

  Future<void> _save() async {
    final input = _input();
    final saved = await ref
        .read(irrigationFormControllerProvider)
        .save(input, calculation: _preview);
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Riego guardado localmente.')));
  }
}
