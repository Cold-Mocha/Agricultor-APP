import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/parcels/data/parcel_repository.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class ParcelFormPage extends ConsumerStatefulWidget {
  const ParcelFormPage({this.parcelId, super.key});

  final String? parcelId;

  @override
  ConsumerState<ParcelFormPage> createState() => _ParcelFormPageState();
}

final class _ParcelFormPageState extends ConsumerState<ParcelFormPage> {
  final _name = TextEditingController();
  final _locality = TextEditingController();
  bool _active = true;

  @override
  void dispose() {
    _name.dispose();
    _locality.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: widget.parcelId == null ? 'Nueva parcela' : 'Editar parcela',
    child: ListView(
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nombre'),
        ),
        const SizedBox(height: AgroSpacing.sm),
        TextField(
          controller: _locality,
          decoration: const InputDecoration(labelText: 'Localidad'),
        ),
        SwitchListTile(
          value: _active,
          onChanged: (value) => setState(() => _active = value),
          title: const Text('Usar como parcela activa'),
        ),
        const SizedBox(height: AgroSpacing.md),
        FilledButton(
          onPressed: () async {
            final ownerId = ref.read(sessionControllerProvider).ownerId;
            if (ownerId == null || _name.text.trim().isEmpty) return;
            await ParcelRepository(ref.read(appDatabaseProvider)).save(
              ownerId: ownerId,
              id: widget.parcelId,
              name: _name.text,
              locality: _locality.text,
              isActive: _active,
            );
            if (context.mounted) context.pop();
          },
          child: const Text('Guardar sin conexión'),
        ),
      ],
    ),
  );
}
