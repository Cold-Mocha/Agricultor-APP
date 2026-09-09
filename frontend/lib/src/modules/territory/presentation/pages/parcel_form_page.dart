import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/territory/presentation/controllers/territory_controllers.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
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
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded && widget.parcelId != null) {
      _loaded = true;
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final row = await ref.read(parcelControllerProvider).load(widget.parcelId!);
    if (row == null || !mounted) return;
    setState(() {
      _name.text = row.name;
      _locality.text = row.locality ?? '';
      _active = row.isActive;
    });
  }

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
            await ref
                .read(parcelControllerProvider)
                .save(
                  ParcelFormInput(
                    ownerId: ownerId,
                    id: widget.parcelId,
                    name: _name.text,
                    locality: _locality.text,
                    isActive: _active,
                  ),
                );
            if (context.mounted) context.pop();
          },
          child: const Text('Guardar sin conexión'),
        ),
      ],
    ),
  );
}
