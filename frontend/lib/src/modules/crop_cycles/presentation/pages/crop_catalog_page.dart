import 'package:agrocampo/src/app/layout/agro_page.dart';
import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/crop_cycles/presentation/controllers/crop_cycles_controller.dart';
import 'package:agrocampo/src/shared/design_system/components/agro_empty_state.dart';
import 'package:agrocampo/src/shared/design_system/components/crop_pictogram.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
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
    final controller = ref.watch(cropsControllerProvider);
    return AgroPage(
      title: 'Catálogo de cultivos',
      subtitle: 'Catálogo oficial y cultivos propios disponibles sin Internet.',
      actions: [
        IconButton(
          tooltip: 'Crear cultivo personalizado',
          onPressed: ownerId == null
              ? null
              : () => _editCustom(controller, ownerId),
          icon: const Icon(Icons.add),
        ),
      ],
      child: ownerId == null
          ? const AgroEmptyState(
              title: 'Sin sesión local',
              message: 'Inicia sesión para administrar cultivos.',
            )
          : FutureBuilder<void>(
              future: controller.ensureCatalog(),
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
                      stream: controller.watchCatalog(
                        ownerId,
                        query: _search.text,
                      ),
                      builder: (context, snapshot) {
                        final crops = snapshot.data ?? const <CropRef>[];
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
                                                controller,
                                                ownerId,
                                                crop: crop,
                                              );
                                            } else {
                                              await controller.archiveCustom(
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
    CropsController controller,
    String ownerId, {
    CropRef? crop,
  }) async {
    final input = await showDialog<CustomCropFormInput>(
      context: context,
      builder: (_) => _CustomCropDialog(
        title: crop == null ? 'Nuevo cultivo' : 'Editar cultivo',
        cropId: crop?.id,
        initialName: crop?.label,
      ),
    );
    try {
      if (input != null) {
        await controller.saveCustom(ownerId: ownerId, input: input);
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

final class _CustomCropDialog extends StatefulWidget {
  const _CustomCropDialog({required this.title, this.cropId, this.initialName});

  final String title;
  final String? cropId;
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
        onPressed: () => Navigator.pop(
          context,
          CustomCropFormInput(
            id: widget.cropId,
            name: _name.text,
            notes: _notes.text,
          ),
        ),
        child: const Text('Guardar'),
      ),
    ],
  );
}
