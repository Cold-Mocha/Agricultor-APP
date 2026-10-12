import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/agricultural_context/agricultural_context_ui.dart';
import 'package:agrocampo/src/modules/soil/presentation/controllers/soil_controller.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SoilMeasurementPage extends ConsumerStatefulWidget {
  const SoilMeasurementPage({this.initialSectorId, super.key});
  final String? initialSectorId;

  @override
  ConsumerState<SoilMeasurementPage> createState() =>
      _SoilMeasurementPageState();
}

final class _SoilMeasurementPageState
    extends ConsumerState<SoilMeasurementPage> {
  final _values = List.generate(7, (_) => TextEditingController());
  static const _labels = [
    'Humedad (%)',
    'pH',
    'Temperatura (°C)',
    'Conductividad EC (mS/cm)',
    'Nitrógeno N (mg/kg)',
    'Fósforo P (mg/kg)',
    'Potasio K (mg/kg)',
  ];
  List<String?> _errors = List.filled(7, null);
  bool _saving = false;
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
    for (final controller in _values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Medición de suelo',
    subtitle: 'Los campos omitidos se conservan como no medidos.',
    child: ListView(
      children: [
        for (var index = 0; index < _values.length; index++) ...[
          TextField(
            controller: _values[index],
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
              signed: index == 2,
            ),
            decoration: InputDecoration(
              labelText: _labels[index],
              errorText: _errors[index],
            ),
          ),
          const SizedBox(height: AgroSpacing.sm),
        ],
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Guardando…' : 'Guardar medición'),
        ),
      ],
    ),
  );

  double? _number(int index) => _values[index].text.trim().isEmpty
      ? null
      : double.tryParse(_values[index].text.trim().replaceAll(',', '.'));

  String? _validateNumber(int index) {
    if (_values[index].text.trim().isEmpty) return null;
    final number = _number(index);
    if (number == null || !number.isFinite) return 'Ingresa un número válido.';
    if (index == 0 && (number < 0 || number > 100)) {
      return 'La humedad debe estar entre 0 y 100 %.';
    }
    if (index == 1 && (number < 0 || number > 14)) {
      return 'El pH debe estar entre 0 y 14.';
    }
    if (index >= 3 && number < 0) {
      return 'El valor debe ser mayor o igual a 0.';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _errors = List.generate(_values.length, _validateNumber));
    if (_errors.any((error) => error != null)) {
      _showMessage('Revisa el formato y los rangos de los campos indicados.');
      return;
    }
    if (_values.every((controller) => controller.text.trim().isEmpty)) {
      _showMessage('Ingresa al menos una medición.');
      return;
    }
    final sectorId = _bound?.sectorId;
    if (sectorId == null) {
      _showMessage('Selecciona un sector agrícola y verifica tu sesión.');
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(soilMeasurementControllerProvider)
          .save(
            sectorId: sectorId,
            input: SoilMeasurementInput(
              moisturePercent: _number(0),
              ph: _number(1),
              temperatureCelsius: _number(2),
              conductivity: _number(3),
              nitrogen: _number(4),
              phosphorus: _number(5),
              potassium: _number(6),
              units: const {
                'moisturePercent': '%',
                'ph': 'pH',
                'temperatureCelsius': '°C',
                'conductivity': 'mS/cm',
                'nitrogen': 'mg/kg',
                'phosphorus': 'mg/kg',
                'potassium': 'mg/kg',
              },
            ),
          );
      if (!mounted) return;
      _showMessage(
        saved
            ? 'Medición guardada.'
            : 'Selecciona un sector agrícola y verifica tu sesión.',
      );
    } on Object {
      if (!mounted) return;
      _showMessage(
        'No fue posible guardar la medición. Tus valores se conservaron; intenta nuevamente.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
