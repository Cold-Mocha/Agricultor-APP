import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/soil/data/soil_repository.dart';
import 'package:agrocampo/features/soil/domain/soil_measurement.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SoilMeasurementPage extends ConsumerStatefulWidget {
  const SoilMeasurementPage({super.key});

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
    'Conductividad EC',
    'Nitrógeno N',
    'Fósforo P',
    'Potasio K',
  ];

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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: _labels[index]),
          ),
          const SizedBox(height: AgroSpacing.sm),
        ],
        FilledButton(onPressed: _save, child: const Text('Guardar medición')),
      ],
    ),
  );

  double? _number(int index) => _values[index].text.trim().isEmpty
      ? null
      : double.tryParse(_values[index].text.replaceAll(',', '.'));

  Future<void> _save() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId;
    final database = ref.read(appDatabaseProvider);
    if (ownerId == null) return;
    final sector = await (database.select(
      database.sectors,
    )..where((row) => row.ownerId.equals(ownerId))).getSingleOrNull();
    if (sector == null) return;
    await SoilRepository(database).save(
      ownerId: ownerId,
      sectorId: sector.id,
      input: SoilMeasurementInput(
        moisturePercent: _number(0),
        ph: _number(1),
        temperatureCelsius: _number(2),
        conductivity: _number(3),
        nitrogen: _number(4),
        phosphorus: _number(5),
        potassium: _number(6),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medición guardada localmente.')),
    );
  }
}
