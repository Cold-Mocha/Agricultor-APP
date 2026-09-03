import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/crops/data/crop_repository.dart';
import 'package:agrocampo/features/crops/data/crop_seed_loader.dart';
import 'package:agrocampo/features/crops/domain/crop_ref.dart';
import 'package:agrocampo/shared/presentation/components/agro_empty_state.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/crop_pictogram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class CropCatalogPage extends ConsumerStatefulWidget {
  const CropCatalogPage({super.key});

  @override
  ConsumerState<CropCatalogPage> createState() => _CropCatalogPageState();
}

final class _CropCatalogPageState extends ConsumerState<CropCatalogPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = ref.watch(unlockedOwnerIdProvider);
    final database = ref.watch(appDatabaseProvider);
    final repository = CropRepository(database);
    return AgroPage(
      title: 'Catálogo de cultivos',
      subtitle: 'Catálogo oficial y cultivos propios disponibles sin Internet.',
      actions: [
        IconButton(
          tooltip: 'Crear cultivo personalizado',
          onPressed: ownerId == null
              ? null
              : () => _editCustom(repository, ownerId),
          icon: const Icon(Icons.add),
        ),
      ],
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin sesión local',
              message: 'Inicia sesión para administrar cultivos.',
            )
          : FutureBuilder<void>(
              future: CropSeedLoader(database).seedIfEmpty(),
              builder: (context, seed) => Column(
                children: [
                  TextField(
                    controller: _search,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Buscar cultivo',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<List<CropRef>>(
                      stream: repository.watchCatalog(ownerId),
                      builder: (context, snapshot) {
                        final query = CropRepository.normalizeName(
                          _search.text,
                        );
                        final crops = (snapshot.data ?? const [])
                            .where(
                              (crop) =>
                                  query.isEmpty ||
                                  CropRepository.normalizeName(crop.label)
                                      .contains(query),
                            )
                            .toList(growable: false);
                        if (crops.isEmpty) {
                          return const AgroEmptyState(
                            title: 'Sin resultados',
                            message:
                                'Prueba otro nombre o crea un cultivo propio.',
                          );
                        }
                        return ListView(
                          children: [
                            for (final crop in crops)
                              Card(
                                child: ListTile(
                                  leading: CropPictogram(
                                    asset: crop.iconAsset,
                                    colorToken: crop.colorToken,
                                  ),
                                  title: Text(crop.label),
                                  subtitle: Text(
                                    crop.archived
                                        ? 'Personalizado · Archivado'
                                        : crop.isCustom
                                        ? 'Personalizado · ${crop.category ?? ''}'
                                        : '${crop.scientificName ?? 'Catálogo oficial'} · ${crop.category ?? ''}',
                                  ),
                                  trailing: crop.isCustom
                                      ? PopupMenuButton<String>(
                                          onSelected: (action) async {
                                            if (action == 'edit') {
                                              await _editCustom(
                                                repository,
                                                ownerId,
                                                crop: crop,
                                              );
                                            } else {
                                              await repository.archiveCustom(
                                                ownerId: ownerId,
                                                id: crop.id,
                                                archived: !crop.archived,
                                              );
                                            }
                                          },
                                          itemBuilder: (_) => [
                                            if (!crop.archived)
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Editar'),
                                              ),
                                            PopupMenuItem(
                                              value: 'archive',
                                              child: Text(
                                                crop.archived
                                                    ? 'Restaurar'
                                                    : 'Archivar',
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Chip(label: Text('Oficial')),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _editCustom(
    CropRepository repository,
    String ownerId, {
    CropRef? crop,
  }) async {
    final input = await showDialog<_CustomCropInput>(
      context: context,
      builder: (_) => _CustomCropDialog(
        title: crop == null ? 'Nuevo cultivo' : 'Editar cultivo',
        initialName: crop?.label,
      ),
    );
    try {
      if (input != null) {
        await repository.saveCustom(
          ownerId: ownerId,
          id: crop?.id,
          name: input.name,
          notes: input.notes,
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
      }
    }
  }
}

final class _CustomCropInput {
  const _CustomCropInput(this.name, this.notes);

  final String name;
  final String notes;
}

final class _CustomCropDialog extends StatefulWidget {
  const _CustomCropDialog({required this.title, this.initialName});

  final String title;
  final String? initialName;

  @override
  State<_CustomCropDialog> createState() => _CustomCropDialogState();
}

final class _CustomCropDialogState extends State<_CustomCropDialog> {
  late final TextEditingController _name;
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          TextField(
            controller: _notes,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notas (opcional)'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () =>
            Navigator.pop(context, _CustomCropInput(_name.text, _notes.text)),
        child: const Text('Guardar'),
      ),
    ],
  );
}
