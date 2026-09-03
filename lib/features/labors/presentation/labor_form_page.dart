import 'dart:convert';

import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/routing/app_routes.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/domain/agricultural_context.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/fertilization_details.dart';
import 'package:agrocampo/features/labors/domain/irrigation_labor_details.dart';
import 'package:agrocampo/features/labors/domain/labor_details.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/features/labors/domain/other_labor_details.dart';
import 'package:agrocampo/features/labors/domain/phytosanitary_details.dart';
import 'package:agrocampo/features/labors/domain/pruning_details.dart';
import 'package:agrocampo/features/labors/domain/sowing_details.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/agro_section_header.dart';
import 'package:agrocampo/shared/presentation/components/bound_agricultural_context_card.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class LaborFormPage extends ConsumerStatefulWidget {
  const LaborFormPage({this.initialSectorId, this.initialLaborType, super.key});
  final String? initialSectorId;
  final LaborType? initialLaborType;

  @override
  ConsumerState<LaborFormPage> createState() => _LaborFormPageState();
}

final class _LaborFormPageState extends ConsumerState<LaborFormPage> {
  late LaborType _type;
  DateTime _occurredAt = DateTime.now();
  final _primary = TextEditingController();
  final _secondary = TextEditingController();
  final _amount = TextEditingController();
  final _unit = TextEditingController();
  final _extra = TextEditingController();
  final _customName = TextEditingController();
  final _notes = TextEditingController();
  BoundAgriculturalContext? _bound;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialLaborType ?? LaborType.fertilization;
  }

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
    for (final controller in [
      _primary,
      _secondary,
      _amount,
      _unit,
      _extra,
      _customName,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Registrar labor',
    subtitle: 'Actividad del cuaderno de campo',
    child: ListView(
      children: [
        const AgroSectionHeader(
          title: '1. Cuadrante y cultivo',
          subtitle: 'Confirma dónde quedará guardada la labor.',
        ),
        const SizedBox(height: AgroSpacing.sm),
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
        const SizedBox(height: AgroSpacing.lg),
        const AgroSectionHeader(
          title: '2. Tipo y fecha',
          subtitle: 'Selecciona la labor que realizaste.',
        ),
        const SizedBox(height: AgroSpacing.sm),
        DropdownButtonFormField<LaborType>(
          key: const ValueKey('labor-type'),
          isExpanded: true,
          initialValue: _type,
          decoration: const InputDecoration(labelText: 'Tipo de labor'),
          items: [
            for (final type in LaborType.values)
              DropdownMenuItem(value: type, child: Text(type.label)),
          ],
          onChanged: (value) => setState(() => _type = value ?? _type),
        ),
        const SizedBox(height: AgroSpacing.sm),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Fecha de la labor'),
          subtitle: Text(
            MaterialLocalizations.of(context).formatMediumDate(_occurredAt),
          ),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: _selectDate,
        ),
        const SizedBox(height: AgroSpacing.md),
        const AgroSectionHeader(
          title: '3. Detalle',
          subtitle: 'Sólo se muestran los datos de esta labor.',
        ),
        _detailsPanel(),
        const SizedBox(height: AgroSpacing.sm),
        TextField(
          key: const ValueKey('labor-notes'),
          controller: _notes,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Observaciones (opcional)',
          ),
        ),
        const SizedBox(height: AgroSpacing.md),
        if (_type == LaborType.irrigation)
          OutlinedButton.icon(
            onPressed: _openIrrigation,
            icon: const Icon(Icons.water_drop_outlined),
            label: const Text('Calcular riego por goteo'),
          ),
        switch (_type) {
          LaborType.harvest => FilledButton.icon(
            onPressed: _openProduction,
            icon: const Icon(Icons.agriculture_outlined),
            label: const Text('Registrar cosecha y producción'),
          ),
          LaborType.soil => FilledButton.icon(
            onPressed: _openSoil,
            icon: const Icon(Icons.science_outlined),
            label: const Text('Abrir medición de suelo'),
          ),
          LaborType.apiary => FilledButton.icon(
            onPressed: _bound?.sectorId == null ? null : _openApiary,
            icon: const Icon(Icons.hive_outlined),
            label: const Text('Abrir revisión apícola'),
          ),
          _ => FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Guardando…' : 'Guardar actividad'),
          ),
        },
      ],
    ),
  );

  Widget _detailsPanel() {
    Widget field(
      String key,
      TextEditingController controller,
      String label, {
      TextInputType? keyboardType,
    }) => Padding(
      padding: const EdgeInsets.only(top: AgroSpacing.sm),
      child: TextField(
        key: ValueKey(key),
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
    final number = const TextInputType.numberWithOptions(decimal: true);
    return Column(
      children: switch (_type) {
        LaborType.fertilization => [
          field('product', _primary, 'Producto o fertilizante'),
          field('amount', _amount, 'Cantidad', keyboardType: number),
          field('unit', _unit, 'Unidad (kg, L)'),
          field('method', _secondary, 'Método de aplicación'),
        ],
        LaborType.diseaseAndPestControl => [
          field('product', _primary, 'Producto'),
          field('target', _secondary, 'Plaga o enfermedad objetivo'),
          field('amount', _amount, 'Dosis', keyboardType: number),
          field('unit', _unit, 'Unidad (ml/L, kg/ha)'),
          field(
            'safety-days',
            _extra,
            'Días de carencia (opcional)',
            keyboardType: number,
          ),
        ],
        LaborType.sowing => [
          field('amount', _amount, 'Cantidad de semilla', keyboardType: number),
          field('unit', _unit, 'Unidad'),
          field(
            'spacing',
            _extra,
            'Distancia entre plantas en cm (opcional)',
            keyboardType: number,
          ),
        ],
        LaborType.pruning => [
          field('method', _primary, 'Método de poda'),
          field(
            'plants',
            _amount,
            'Plantas intervenidas (opcional)',
            keyboardType: number,
          ),
        ],
        LaborType.other => [
          field('custom-name', _customName, 'Nombre de la labor'),
          field('description', _primary, 'Descripción'),
        ],
        LaborType.irrigation => [
          field('method', _primary, 'Método'),
          field(
            'duration',
            _amount,
            'Duración en minutos',
            keyboardType: number,
          ),
          field(
            'volume',
            _extra,
            'Volumen aplicado en litros (opcional)',
            keyboardType: number,
          ),
        ],
        LaborType.harvest => const [
          Padding(
            padding: EdgeInsets.only(top: AgroSpacing.sm),
            child: Text(
              'La cosecha se registra junto con su producción para evitar duplicados.',
            ),
          ),
        ],
        LaborType.soil || LaborType.apiary => const [
          Padding(
            padding: EdgeInsets.only(top: AgroSpacing.sm),
            child: Text(
              'Este registro conserva el flujo especializado existente.',
            ),
          ),
        ],
      },
    );
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0;

  LaborDetails _details() => switch (_type) {
    LaborType.fertilization => FertilizationDetails(
      product: _primary.text,
      amount: _number(_amount),
      unit: _unit.text,
      applicationMethod: _secondary.text,
    ).toEnvelope(),
    LaborType.diseaseAndPestControl => PhytosanitaryDetails(
      product: _primary.text,
      target: _secondary.text,
      dose: _number(_amount),
      unit: _unit.text,
      safetyIntervalDays: int.tryParse(_extra.text.trim()),
    ).toEnvelope(),
    LaborType.sowing => SowingDetails(
      seedQuantity: _number(_amount),
      unit: _unit.text,
      spacingCentimeters: _extra.text.trim().isEmpty ? null : _number(_extra),
    ).toEnvelope(),
    LaborType.pruning => PruningDetails(
      method: _primary.text,
      plantCount: _amount.text.trim().isEmpty
          ? null
          : int.tryParse(_amount.text.trim()),
    ).toEnvelope(),
    LaborType.other => OtherLaborDetails(
      name: _customName.text,
      description: _primary.text,
    ).toEnvelope(),
    LaborType.irrigation => IrrigationLaborDetails(
      method: _primary.text,
      durationMinutes: int.tryParse(_amount.text.trim()) ?? 0,
      appliedVolumeLiters: _extra.text.trim().isEmpty ? null : _number(_extra),
    ).toEnvelope(),
    LaborType.soil || LaborType.apiary => LaborDetails.current(_type, const {}),
    LaborType.harvest => throw StateError('harvest_uses_production_flow'),
  };

  Future<void> _selectDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (value != null) setState(() => _occurredAt = value);
  }

  void _openIrrigation() =>
      context.push(AppRoutes.irrigationFor(sectorId: _bound?.sectorId));
  void _openProduction() =>
      context.push(AppRoutes.productionFor(sectorId: _bound?.sectorId));
  void _openSoil() =>
      context.push(AppRoutes.soilFor(sectorId: _bound?.sectorId));
  void _openApiary() => context.push(AppRoutes.sectorApiary(_bound!.sectorId!));

  Future<void> _save() async {
    final ownerId = ref.read(unlockedOwnerIdProvider);
    final database = ref.read(appDatabaseProvider);
    final sectorId = _bound?.sectorId;
    if (ownerId == null || sectorId == null) return;
    setState(() => _saving = true);
    try {
      final sector =
          await (database.select(database.sectors)..where(
                (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
              ))
              .getSingle();
      await LaborRepository(database).save(
        ownerId: ownerId,
        parcelId: sector.parcelId,
        sectorId: sector.id,
        type: _type,
        occurredAt: _occurredAt.toUtc(),
        details: _details(),
        customName: _type == LaborType.other ? _customName.text : null,
        notes: _notes.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Actividad guardada localmente · pendiente de sincronizar',
          ),
        ),
      );
    } on Object {
      await database.formDraftDao.save(
        ownerId,
        'labor',
        jsonEncode({
          'type': _type.name,
          'primary': _primary.text,
          'secondary': _secondary.text,
          'amount': _amount.text,
          'unit': _unit.text,
          'extra': _extra.text,
          'customName': _customName.text,
          'notes': _notes.text,
        }),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los datos; el borrador se conservó.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
