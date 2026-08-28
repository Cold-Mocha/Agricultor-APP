import 'dart:io';

import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/core/files/private_file_store.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:agrocampo/features/photos/data/photo_repository.dart';
import 'package:agrocampo/features/photos/domain/photo_attachment.dart';
import 'package:agrocampo/shared/presentation/components/agro_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final class PhotoAttachmentPage extends ConsumerStatefulWidget {
  const PhotoAttachmentPage({super.key});

  @override
  ConsumerState<PhotoAttachmentPage> createState() =>
      _PhotoAttachmentPageState();
}

final class _PhotoAttachmentPageState
    extends ConsumerState<PhotoAttachmentPage> {
  XFile? _selected;

  @override
  Widget build(BuildContext context) => AgroPage(
    title: 'Fotografías',
    subtitle: 'Adjuntos privados disponibles sin conexión',
    child: ListView(
      children: [
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
            child: Image.file(File(_selected!.path), fit: BoxFit.cover),
          ),
        const SizedBox(height: AgroSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Cámara'),
              ),
            ),
            const SizedBox(width: AgroSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
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

  Future<void> _pick(ImageSource source) async {
    final selected = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (selected != null && mounted) setState(() => _selected = selected);
  }

  Future<void> _save() async {
    final ownerId = ref.read(sessionControllerProvider).ownerId;
    final database = ref.read(appDatabaseProvider);
    if (ownerId == null || _selected == null) return;
    final sector = await (database.select(
      database.sectors,
    )..where((row) => row.ownerId.equals(ownerId))).getSingleOrNull();
    if (sector == null) return;
    await PhotoRepository(database, PrivateFileStore()).attach(
      PhotoAttachmentInput(
        ownerId: ownerId,
        aggregateType: 'sector',
        aggregateId: sector.id,
        sourcePath: _selected!.path,
        mimeType: _selected!.mimeType ?? 'image/jpeg',
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fotografía guardada localmente.')),
    );
  }
}
