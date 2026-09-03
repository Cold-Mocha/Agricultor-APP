import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/routing/app_routes.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/domain/agricultural_context.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/irrigation/data/irrigation_estimate_repository.dart';
import 'package:agrocampo/features/irrigation/data/irrigation_repository.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_calculator.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_explanation.dart';
import 'package:agrocampo/features/irrigation/domain/irrigation_record.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/agro_status_banner.dart';
import 'package:agrocampo/shared/presentation/components/bound_agricultural_context_card.dart';
import 'package:drift/drift.dart' hide Column;
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
  IrrigationPreview? _preview;

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

  Future<void> _calculate() async {
    if (_type != IrrigationType.drip) {
      setState(
        () => _calculationMessage =
            '002 solo calcula recomendaciones para riego por goteo.',
      );
      return;
    }
    final ownerId = ref.read(unlockedOwnerIdProvider);
    final database = ref.read(appDatabaseProvider);
    final sectorId = _bound?.sectorId;
    if (ownerId == null || sectorId == null) return;
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return;
    final preview = await IrrigationEstimateRepository(database)
        .calculateForSector(
          ownerId: ownerId,
          parcelId: sector.parcelId,
          sectorId: sector.id,
          soilTypeCode: _soil.name,
          occurredAt: DateTime.now().toUtc(),
          performedDurationSeconds: (int.tryParse(_duration.text) ?? 0) * 60,
        );
    final result = preview.result;
    if (!mounted) return;
    setState(() {
      _calculationMessage = switch (result) {
        IrrigationUnavailable(:final code) =>
          code == 'drip_config_unavailable'
              ? 'Configura plantas, goteros y caudal del sector antes de calcular.'
              : code == 'crop_rule_unavailable'
              ? 'Regla agronómica no disponible. Puedes guardar el riego básico sin recomendación.'
              : 'Completa entradas positivas para calcular.',
        IrrigationEstimateResult() => IrrigationExplanation.short(result),
      };
      _preview = preview;
    });
  }

  Future<void> _save() async {
    final ownerId = ref.read(unlockedOwnerIdProvider);
    final database = ref.read(appDatabaseProvider);
    final sectorId = _bound?.sectorId;
    if (ownerId == null || sectorId == null) return;
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return;
    IrrigationPreview? preview = _preview;
    if (_type == IrrigationType.drip && preview == null) {
      preview = await IrrigationEstimateRepository(database).calculateForSector(
        ownerId: ownerId,
        parcelId: sector.parcelId,
        sectorId: sector.id,
        soilTypeCode: _soil.name,
        occurredAt: DateTime.now().toUtc(),
        performedDurationSeconds: (int.tryParse(_duration.text) ?? 0) * 60,
      );
    }
    await IrrigationRepository(database).savePerformed(
      ownerId: ownerId,
      parcelId: sector.parcelId,
      sectorId: sector.id,
      occurredAt: DateTime.now().toUtc(),
      preview: preview,
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
