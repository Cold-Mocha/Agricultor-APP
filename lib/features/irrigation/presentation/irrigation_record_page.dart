import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/irrigation/data/irrigation_estimate_repository.dart';
import 'package:agrocampo/features/irrigation/data/irrigation_repository.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_record.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/agro_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class IrrigationRecordPage extends ConsumerStatefulWidget {
  const IrrigationRecordPage({super.key});

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
  final _plants = TextEditingController();
  String _calculationMessage =
      'Regla agronómica no disponible para este cultivo y tipo de suelo.';

  @override
  void dispose() {
    _duration.dispose();
    _flow.dispose();
    _plants.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Riego',
    subtitle: 'Registro básico disponible sin conexión',
    child: ListView(
      children: [
        DropdownButtonFormField(
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
        TextField(
          controller: _flow,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Caudal (litros/hora, opcional)',
          ),
        ),
        const SizedBox(height: AgroSpacing.md),
        TextField(
          controller: _plants,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cantidad de plantas (para cálculo)',
          ),
        ),
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

  Future<void> _calculate() async {
    final result =
        await IrrigationEstimateRepository(
          ref.read(appDatabaseProvider),
        ).calculate(
          cropId: 'unassigned',
          soilTypeCode: _soil.name,
          input: IrrigationCalculationInput(
            plantCount: int.tryParse(_plants.text) ?? 0,
            flowMilliLitersPerHourPerPlant:
                ((double.tryParse(_flow.text.replaceAll(',', '.')) ?? 0) * 1000)
                    .round(),
            requestedMinutes: int.tryParse(_duration.text) ?? 0,
          ),
        );
    if (!mounted) return;
    setState(() {
      _calculationMessage = switch (result) {
        IrrigationUnavailable(:final code) =>
          code == 'crop_rule_unavailable'
              ? 'Regla agronómica no disponible. Puedes guardar el riego básico sin recomendación.'
              : 'Completa entradas positivas para calcular.',
        IrrigationEstimateResult(
          :final estimatedLitersMilli,
          :final recommendedMinutes,
        ) =>
          '${(estimatedLitersMilli / 1000).toStringAsFixed(1)} L · $recommendedMinutes min · cálculo determinístico',
      };
    });
  }

  Future<void> _save() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId;
    final database = ref.read(appDatabaseProvider);
    if (ownerId == null) return;
    final sector = await (database.select(
      database.sectors,
    )..where((row) => row.ownerId.equals(ownerId))).getSingleOrNull();
    if (sector == null) return;
    await IrrigationRepository(database).saveBasic(
      ownerId: ownerId,
      sectorId: sector.id,
      input: BasicIrrigationInput(
        type: _type,
        soilType: _soil,
        durationMinutes: int.tryParse(_duration.text) ?? 0,
        flowLitersPerHour: double.tryParse(_flow.text.replaceAll(',', '.')),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Riego guardado localmente.')));
  }
}
