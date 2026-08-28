import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/production/data/production_repository.dart';
import 'package:agrocampo/features/production/domain/harvest_input.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ProductionPage extends ConsumerStatefulWidget {
  const ProductionPage({super.key});

  @override
  ConsumerState<ProductionPage> createState() => _ProductionPageState();
}

final class _ProductionPageState extends ConsumerState<ProductionPage> {
  final _crop = TextEditingController();
  final _quantity = TextEditingController();
  final _unit = TextEditingController(text: 'kg');

  @override
  void dispose() {
    _crop.dispose();
    _quantity.dispose();
    _unit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Producción',
    subtitle: 'Cosecha trazable por sector y temporada',
    child: ListView(
      children: [
        TextField(
          controller: _crop,
          decoration: const InputDecoration(labelText: 'Cultivo'),
        ),
        const SizedBox(height: AgroSpacing.sm),
        TextField(
          controller: _quantity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Cantidad'),
        ),
        const SizedBox(height: AgroSpacing.sm),
        TextField(
          controller: _unit,
          decoration: const InputDecoration(labelText: 'Unidad'),
        ),
        const SizedBox(height: AgroSpacing.md),
        FilledButton(onPressed: _save, child: const Text('Guardar cosecha')),
      ],
    ),
  );

  Future<void> _save() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId;
    final database = ref.read(appDatabaseProvider);
    if (ownerId == null) return;
    final sector = await (database.select(
      database.sectors,
    )..where((row) => row.ownerId.equals(ownerId))).getSingleOrNull();
    if (sector == null) return;
    await ProductionRepository(database).save(
      ownerId: ownerId,
      parcelId: sector.parcelId,
      sectorId: sector.id,
      input: HarvestInput(
        cropId: _crop.text.trim(),
        quantity: double.tryParse(_quantity.text.replaceAll(',', '.')) ?? 0,
        unit: _unit.text,
        harvestedAt: DateTime.now().toUtc(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cosecha guardada localmente.')),
    );
  }
}
