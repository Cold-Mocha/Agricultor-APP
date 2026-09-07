import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/bound_agricultural_context_card.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
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
        FutureBuilder<HarvestContextUiState?>(
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

  Future<HarvestContextUiState?> _loadContext() =>
      ref.read(productionControllerProvider).loadContext(_bound?.sectorId);

  Future<void> _save() async {
    final sectorId = _bound?.sectorId;
    if (sectorId == null) {
      _showMissingContext();
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await ref
          .read(productionControllerProvider)
          .save(
            ProductionFormInput(
              sectorId: sectorId,
              quantity: _quantity.text,
              unit: _unit,
              qualityNotes: _quality.text,
            ),
          );
      if (!mounted) return;
      if (result == ProductionSaveStatus.missingContext) {
        _showMissingContext();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cosecha guardada localmente · pendiente de sincronizar',
          ),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa la cantidad y el contexto agrícola.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMissingContext() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selecciona un sector con temporada y cultivo vigentes.'),
      ),
    );
  }
}
