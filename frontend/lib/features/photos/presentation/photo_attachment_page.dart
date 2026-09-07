import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/shared/presentation/components/agricultural_context_selector.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:agrocampo/shared/presentation/components/bound_agricultural_context_card.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class PhotoAttachmentPage extends ConsumerStatefulWidget {
  const PhotoAttachmentPage({this.initialSectorId, super.key});
  final String? initialSectorId;

  @override
  ConsumerState<PhotoAttachmentPage> createState() =>
      _PhotoAttachmentPageState();
}

final class _PhotoAttachmentPageState
    extends ConsumerState<PhotoAttachmentPage> {
  PhotoSelectionUiState? _selected;
  BoundAgriculturalContext? _bound;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bound ??= BoundAgriculturalContext.from(
      ref.read(agriculturalContextControllerProvider),
      sectorId: widget.initialSectorId,
    );
  }

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Fotografías',
    subtitle: 'Adjuntos privados disponibles sin conexión',
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
        if (_selected == null)
          const AspectRatio(
            aspectRatio: 4 / 3,
            child: Card(
              child: Center(child: Icon(Icons.add_a_photo_outlined, size: 64)),
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(AgroRadii.medium),
            child: Image.memory(_selected!.previewBytes, fit: BoxFit.cover),
          ),
        const SizedBox(height: AgroSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(PhotoSelectionSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Cámara'),
              ),
            ),
            const SizedBox(width: AgroSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(PhotoSelectionSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galería'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AgroSpacing.md),
        FilledButton(
          onPressed: _selected == null ? null : _save,
          child: const Text('Adjuntar fotografía'),
        ),
      ],
    ),
  );

  Future<void> _pick(PhotoSelectionSource source) async {
    final selected = await ref
        .read(photoAttachmentControllerProvider)
        .pick(source);
    if (selected != null && mounted) setState(() => _selected = selected);
  }

  Future<void> _save() async {
    final sectorId = _bound?.sectorId;
    final selected = _selected;
    if (sectorId == null || selected == null) return;
    final saved = await ref
        .read(photoAttachmentControllerProvider)
        .attach(sectorId: sectorId, selection: selected);
    if (!mounted || !saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fotografía guardada localmente.')),
    );
  }
}
