import 'dart:convert';

import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/labors/data/labor_repository.dart';
import 'package:agrocampo/features/labors/domain/labor_type.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class LaborFormPage extends ConsumerStatefulWidget {
  const LaborFormPage({super.key});

  @override
  ConsumerState<LaborFormPage> createState() => _LaborFormPageState();
}

final class _LaborFormPageState extends ConsumerState<LaborFormPage> {
  LaborType _type = LaborType.fertilization;
  final _customName = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _customName.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'LABORES',
    subtitle: 'Registrar actividad en terreno',
    child: ListView(
      children: [
        DropdownButtonFormField<LaborType>(
          isExpanded: true,
          initialValue: _type,
          decoration: const InputDecoration(labelText: 'Tipo de labor'),
          items: [
            for (final type in LaborType.values)
              DropdownMenuItem(value: type, child: Text(type.label)),
          ],
          onChanged: (value) => setState(() => _type = value ?? _type),
        ),
        if (_type == LaborType.other) ...[
          const SizedBox(height: AgroSpacing.sm),
          TextField(
            controller: _customName,
            decoration: const InputDecoration(labelText: 'Nombre de la labor'),
          ),
        ],
        const SizedBox(height: AgroSpacing.sm),
        TextField(
          controller: _notes,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'Observaciones'),
        ),
        const SizedBox(height: AgroSpacing.md),
        FilledButton(onPressed: _save, child: const Text('Guardar actividad')),
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
    try {
      await LaborRepository(database).save(
        ownerId: ownerId,
        parcelId: sector.parcelId,
        sectorId: sector.id,
        type: _type,
        occurredAt: DateTime.now().toUtc(),
        customName: _customName.text,
        notes: _notes.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actividad guardada localmente.')),
      );
    } on Object {
      await database.formDraftDao.save(
        ownerId,
        'labor',
        jsonEncode({
          'type': _type.name,
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
    }
  }
}
