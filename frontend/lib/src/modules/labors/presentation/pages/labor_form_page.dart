import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/labors/presentation/controllers/labors_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_section_header.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _fertilizationMethodCodes = ['manual', 'foliar', 'fertigation'];

final class LaborFormPage extends ConsumerStatefulWidget {
  const LaborFormPage({
    this.initialSectorId,
    this.initialLaborType,
    this.editLaborId,
    super.key,
  });
  final String? initialSectorId;
  final LaborType? initialLaborType;

  /// When set, the page reopens this labor for correction instead of
  /// creating a new one: the type becomes fixed and saving calls
  /// `correctTyped`, which supersedes the original.
  final String? editLaborId;

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
  String _fertilizationMethod = 'manual';
  bool get _editing => widget.editLaborId != null;
  bool _loadingDraft = false;
  bool _draftUnavailable = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialLaborType ?? LaborType.fertilization;
    if (_editing) {
      _loadingDraft = true;
      _loadDraft(widget.editLaborId!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bound == null && !_editing) {
      _bound = BoundAgriculturalContext.from(
        ref.read(agriculturalContextControllerProvider),
        sectorId: widget.initialSectorId,
      );
      _keepTypeCompatible();
    }
  }

  Future<void> _loadDraft(String laborId) async {
    final draft = await ref
        .read(laborFormControllerProvider)
        .loadForEdit(laborId);
    if (!mounted) return;
    if (draft == null) {
      setState(() {
        _loadingDraft = false;
        _draftUnavailable = true;
      });
      return;
    }
    setState(() {
      _type = draft.type;
      _occurredAt = draft.occurredAt;
      _bound = BoundAgriculturalContext.from(
        ref.read(agriculturalContextControllerProvider),
        sectorId: draft.sectorId,
      );
      if (_type == LaborType.fertilization &&
          _fertilizationMethodCodes.contains(draft.secondary)) {
        _fertilizationMethod = draft.secondary;
      } else {
        _secondary.text = draft.secondary;
      }
      _primary.text = draft.primary;
      _amount.text = draft.amount;
      _unit.text = draft.unit;
      _extra.text = draft.extra;
      _customName.text = draft.customName;
      _notes.text = draft.notes;
      _loadingDraft = false;
    });
  }

  /// Mirrors DomainCompatibilityPolicy: apiary sectors only accept apiary
  /// work and every other sector excludes it.
  List<LaborType> get _availableTypes =>
      _bound?.category == ProductiveCategory.apiary
      ? const [LaborType.apiary]
      : [
          for (final type in LaborType.values)
            if (type != LaborType.apiary) type,
        ];

  void _keepTypeCompatible() {
    final types = _availableTypes;
    if (!types.contains(_type)) _type = types.first;
  }

  IconData _iconFor(LaborType type) => switch (type) {
    LaborType.irrigation => LucideIcons.droplet,
    LaborType.soil => LucideIcons.flaskConical,
    LaborType.fertilization => LucideIcons.sprayCan,
    LaborType.diseaseAndPestControl => LucideIcons.bug,
    LaborType.cultivation => LucideIcons.tractor,
    LaborType.sowing => LucideIcons.sprout,
    LaborType.pruning => LucideIcons.scissors,
    LaborType.harvest => LucideIcons.wheat,
    LaborType.apiary => Icons.emoji_nature,
    LaborType.other => LucideIcons.ellipsis,
  };

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
  Widget build(BuildContext context) {
    if (_loadingDraft) {
      return AgroPage(
        title: 'Corregir labor',
        subtitle: 'Actividad del cuaderno de campo',
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_draftUnavailable) {
      return AgroPage(
        title: 'Corregir labor',
        subtitle: 'Actividad del cuaderno de campo',
        child: const AgroEmptyState(
          title: 'No disponible para corrección',
          message:
              'Esta labor ya fue corregida, anulada, o no admite un '
              'formulario genérico de corrección.',
        ),
      );
    }
    return AgroPage(
      title: _editing ? 'Corregir labor' : 'Registrar labor',
      subtitle: 'Actividad del cuaderno de campo',
      child: ListView(
        children: [
          const AgroSectionHeader(
            title: '1. Tipo y fecha',
            subtitle: 'Selecciona la labor que realizaste.',
          ),
          const SizedBox(height: AgroSpacing.sm),
          DropdownButtonFormField<LaborType>(
            key: const ValueKey('labor-type'),
            isExpanded: true,
            initialValue: _type,
            decoration: InputDecoration(
              labelText: 'Tipo de labor',
              helperText: _editing
                  ? 'El tipo no se puede cambiar al corregir.'
                  : null,
            ),
            items: [
              for (final type in _availableTypes)
                DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(_iconFor(type), size: 18),
                      const SizedBox(width: AgroSpacing.sm),
                      Text(type.label),
                    ],
                  ),
                ),
            ],
            onChanged: _editing
                ? null
                : (value) => setState(() => _type = value ?? _type),
          ),
          const SizedBox(height: AgroSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Fecha de la labor'),
            subtitle: Text(
              MaterialLocalizations.of(context).formatMediumDate(_occurredAt),
            ),
            trailing: const Icon(LucideIcons.calendar),
            onTap: _selectDate,
          ),
          const SizedBox(height: AgroSpacing.md),
          const AgroSectionHeader(
            title: '2. Detalle',
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
              icon: const Icon(LucideIcons.droplet),
              label: const Text('Calcular riego por goteo'),
            ),
          switch (_type) {
            LaborType.harvest => FilledButton.icon(
              onPressed: _openProduction,
              icon: const Icon(LucideIcons.wheat),
              label: const Text('Registrar cosecha y producción'),
            ),
            LaborType.soil => FilledButton.icon(
              onPressed: _openSoil,
              icon: const Icon(LucideIcons.flaskConical),
              label: const Text('Abrir medición de suelo'),
            ),
            LaborType.apiary => FilledButton.icon(
              onPressed: _bound?.sectorId == null ? null : _openApiary,
              icon: const Icon(Icons.emoji_nature),
              label: const Text('Abrir revisión apícola'),
            ),
            _ => FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving
                    ? 'Guardando…'
                    : _editing
                    ? 'Guardar corrección'
                    : 'Guardar actividad',
              ),
            ),
          },
        ],
      ),
    );
  }

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
          Padding(
            padding: const EdgeInsets.only(top: AgroSpacing.sm),
            child: DropdownButtonFormField<String>(
              key: const ValueKey('fertilization-method'),
              initialValue: _fertilizationMethod,
              decoration: const InputDecoration(labelText: 'Método'),
              items: const [
                DropdownMenuItem(value: 'manual', child: Text('Manual')),
                DropdownMenuItem(value: 'foliar', child: Text('Foliar')),
                DropdownMenuItem(
                  value: 'fertigation',
                  child: Text('Fertirriego'),
                ),
              ],
              onChanged: (value) => setState(
                () => _fertilizationMethod = value ?? _fertilizationMethod,
              ),
            ),
          ),
          field('product', _primary, 'Producto o fertilizante'),
          field('amount', _amount, 'Cantidad', keyboardType: number),
          field('unit', _unit, 'Unidad (kg, L)'),
          field('method', _secondary, 'Detalle del método (opcional)'),
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
        LaborType.cultivation => [
          field('performed-work', _primary, 'Labor realizada'),
          field('observed-state', _secondary, 'Estado observado'),
          field('variety', _extra, 'Variedad (opcional)'),
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
    final sectorId = _bound?.sectorId;
    if (sectorId == null) return;
    setState(() => _saving = true);
    try {
      final input = LaborFormInput(
        sectorId: sectorId,
        type: _type,
        occurredAt: _occurredAt,
        primary: _primary.text,
        secondary:
            _type == LaborType.fertilization && _secondary.text.trim().isEmpty
            ? _fertilizationMethod
            : _secondary.text,
        amount: _amount.text,
        unit: _unit.text,
        extra: _extra.text,
        customName: _customName.text,
        notes: _notes.text,
      );
      final controller = ref.read(laborFormControllerProvider);
      final outcome = _editing
          ? await controller.correctTyped(widget.editLaborId!, input)
          : await controller.saveTyped(input);
      if (!mounted || outcome == null) return;
      final message = switch (outcome) {
        SavedLocal<LaborFormInput>() =>
          _editing ? 'Corrección guardada.' : 'Actividad guardada.',
        ValidationFailed<LaborFormInput>() ||
        DomainRejected<LaborFormInput>() =>
          'Revisa los datos; el borrador se conservó.',
        StorageFailed<LaborFormInput>() || StaleVersion<LaborFormInput>() =>
          'No se pudo guardar; el comando y el borrador se conservaron.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
