import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/domain/agricultural_context.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/production/data/production_repository.dart';
import 'package:agrocampo/features/production/domain/harvest_input.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/bound_agricultural_context_card.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ProductionPage extends ConsumerStatefulWidget {
  const ProductionPage({this.initialSectorId, super.key});
  final String? initialSectorId;

  @override
  ConsumerState<ProductionPage> createState() => _ProductionPageState();
}

final class _ProductionPageState extends ConsumerState<ProductionPage> {
  final _quantity = TextEditingController();
  final _quality = TextEditingController();
  String _unit = 'kg';
  BoundAgriculturalContext? _bound;
  bool _saving = false;

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
    _quantity.dispose();
    _quality.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Producción',
    subtitle: 'Cosecha trazable por sector y temporada',
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
        FutureBuilder<_HarvestContext?>(
          future: _loadContext(),
          builder: (context, snapshot) {
            final value = snapshot.data;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.eco_outlined),
                title: Text(
                  value?.cropName ?? 'Selecciona un sector con cultivo vigente',
                ),
                subtitle: Text(
                  value == null
                      ? 'Cultivo y temporada no se escriben manualmente.'
                      : '${value.seasonName} · contexto de solo lectura',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AgroSpacing.sm),
        TextField(
          key: const ValueKey('production-quantity'),
          controller: _quantity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Cantidad cosechada'),
        ),
        const SizedBox(height: AgroSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: _unit,
          decoration: const InputDecoration(labelText: 'Unidad'),
          items: const [
            DropdownMenuItem(value: 'kg', child: Text('Kilogramos (kg)')),
            DropdownMenuItem(value: 't', child: Text('Toneladas (t)')),
            DropdownMenuItem(value: 'cajas', child: Text('Cajas')),
          ],
          onChanged: (value) => setState(() => _unit = value ?? _unit),
        ),
        const SizedBox(height: AgroSpacing.sm),
        TextField(
          controller: _quality,
          decoration: const InputDecoration(
            labelText: 'Calidad u observaciones (opcional)',
          ),
        ),
        const SizedBox(height: AgroSpacing.md),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Guardando…' : 'Guardar cosecha'),
        ),
      ],
    ),
  );

  Future<_HarvestContext?> _loadContext() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId;
    final database = ref.read(appDatabaseProvider);
    final sectorId = _bound?.sectorId;
    if (ownerId == null || sectorId == null) {
      return null;
    }
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return null;
    try {
      final context = await LaborRepository(database).resolveContext(
        ownerId: ownerId,
        parcelId: sector.parcelId,
        sectorId: sector.id,
        occurredAt: DateTime.now().toUtc(),
      );
      final season = await (database.select(
        database.agriculturalSeasons,
      )..where((row) => row.id.equals(context.seasonId))).getSingle();
      final cropName = context.isCustomCrop
          ? (await (database.select(
              database.customCrops,
            )..where((row) => row.id.equals(context.cropId))).getSingle()).name
          : (await (database.select(
                  database.officialCrops,
                )..where((row) => row.id.equals(context.cropId))).getSingle())
                .commonName;
      return _HarvestContext(sector.parcelId, context, season.name, cropName);
    } on Object {
      return null;
    }
  }

  Future<void> _save() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId;
    final context = await _loadContext();
    if (ownerId == null || context == null) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selecciona un sector con temporada y cultivo vigentes.',
            ),
          ),
        );
      }
      return;
    }
    setState(() => _saving = true);
    try {
      await ProductionRepository(ref.read(appDatabaseProvider)).save(
        ownerId: ownerId,
        parcelId: context.parcelId,
        sectorId: context.context.sectorId,
        seasonId: context.context.seasonId,
        cropAssignmentId: context.context.assignmentId,
        input: HarvestInput(
          cropId: context.context.cropId,
          quantity: double.tryParse(_quantity.text.replaceAll(',', '.')) ?? 0,
          unit: _unit,
          qualityNotes: _quality.text,
          harvestedAt: DateTime.now().toUtc(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cosecha guardada localmente · pendiente de sincronizar',
          ),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Revisa la cantidad y el contexto agrícola.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

final class _HarvestContext {
  const _HarvestContext(
    this.parcelId,
    this.context,
    this.seasonName,
    this.cropName,
  );
  final String parcelId;
  final LaborContext context;
  final String seasonName;
  final String cropName;
}
