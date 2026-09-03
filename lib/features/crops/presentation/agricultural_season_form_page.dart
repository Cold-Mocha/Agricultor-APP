import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/context/presentation/agricultural_context_controller.dart';
import 'package:agrocampo/features/crops/data/agricultural_season_repository.dart';
import 'package:agrocampo/features/crops/domain/agricultural_season.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AgriculturalSeasonFormPage extends ConsumerStatefulWidget {
  const AgriculturalSeasonFormPage({this.seasonId, super.key});

  final String? seasonId;

  @override
  ConsumerState<AgriculturalSeasonFormPage> createState() =>
      _AgriculturalSeasonFormPageState();
}

final class _AgriculturalSeasonFormPageState
    extends ConsumerState<AgriculturalSeasonFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _notes = TextEditingController();
  DateTime _startsOn = DateTime.now();
  DateTime? _endsOn;
  AgriculturalSeasonStatus _status = AgriculturalSeasonStatus.planned;
  bool _loaded = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (widget.seasonId == null) return;
    final database = ref.read(appDatabaseProvider);
    final row = await (database.select(
      database.agriculturalSeasons,
    )..where((item) => item.id.equals(widget.seasonId!))).getSingleOrNull();
    if (row == null || !mounted) return;
    setState(() {
      _name.text = row.name;
      _notes.text = row.notes ?? '';
      _startsOn = row.startsOn;
      _endsOn = row.endsOn;
      _status = AgriculturalSeasonStatus.values.byName(row.status);
    });
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: widget.seasonId == null ? 'Nueva temporada' : 'Editar temporada',
    subtitle: 'La temporada conserva el historial de cultivos y labores.',
    child: Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nombre'),
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'Ingresa un nombre.' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AgriculturalSeasonStatus>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Estado'),
            items: const [
              DropdownMenuItem(
                value: AgriculturalSeasonStatus.planned,
                child: Text('Planificada'),
              ),
              DropdownMenuItem(
                value: AgriculturalSeasonStatus.active,
                child: Text('Activa'),
              ),
              DropdownMenuItem(
                value: AgriculturalSeasonStatus.closed,
                child: Text('Cerrada'),
              ),
            ],
            onChanged: (value) => setState(() {
              _status = value!;
              if (_status == AgriculturalSeasonStatus.closed) {
                _endsOn ??= DateTime.now();
              }
            }),
          ),
          const SizedBox(height: 12),
          _DateTile(
            label: 'Inicio',
            value: _startsOn,
            onTap: () async {
              final value = await showDatePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDate: _startsOn,
              );
              if (value != null) setState(() => _startsOn = value);
            },
          ),
          if (_status == AgriculturalSeasonStatus.closed)
            _DateTile(
              label: 'Término',
              value: _endsOn!,
              onTap: () async {
                final value = await showDatePicker(
                  context: context,
                  firstDate: _startsOn,
                  lastDate: DateTime(2100),
                  initialDate: _endsOn!,
                );
                if (value != null) setState(() => _endsOn = value);
              },
            ),
          TextFormField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Notas (opcional)'),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Guardando…' : 'Guardar localmente'),
          ),
        ],
      ),
    ),
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ownerId = ref.read(unlockedOwnerIdProvider);
    final parcelId = ref.read(agriculturalContextControllerProvider).parcelId;
    if (ownerId == null || parcelId == null) return;
    setState(() => _saving = true);
    try {
      final id =
          await AgriculturalSeasonRepository(
            ref.read(appDatabaseProvider),
          ).save(
            ownerId: ownerId,
            parcelId: parcelId,
            id: widget.seasonId,
            name: _name.text,
            startsOn: _startsOn,
            endsOn: _status == AgriculturalSeasonStatus.closed ? _endsOn : null,
            status: _status,
            notes: _notes.text,
          );
      await ref
          .read(agriculturalContextControllerProvider.notifier)
          .selectSeason(id);
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

final class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.calendar_month_outlined),
    title: Text(label),
    subtitle: Text('${value.day}/${value.month}/${value.year}'),
    onTap: onTap,
  );
}
