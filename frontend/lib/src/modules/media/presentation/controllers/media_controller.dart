import 'dart:typed_data';

import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum PhotoSelectionSource { camera, gallery }

final class PhotoSelectionUiState {
  const PhotoSelectionUiState._(this.previewBytes, this._source);

  final Uint8List previewBytes;
  final XFile _source;
}

final photoAttachmentControllerProvider = Provider<PhotoAttachmentController>(
  PhotoAttachmentController.new,
);

final class PhotoAttachmentController {
  PhotoAttachmentController(this._ref);

  final Ref _ref;

  Future<PhotoSelectionUiState?> pick(PhotoSelectionSource source) async {
    final selected = await ImagePicker().pickImage(
      source: source == PhotoSelectionSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (selected == null) return null;
    return PhotoSelectionUiState._(await selected.readAsBytes(), selected);
  }

  Future<bool> attach({
    required String sectorId,
    required PhotoSelectionUiState selection,
  }) async {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) return false;
    return _ref
        .read(mediaFacadeProvider)
        .attach(
          ownerId: ownerId,
          sectorId: sectorId,
          sourcePath: selection._source.path,
          mimeType: selection._source.mimeType ?? 'image/jpeg',
        );
  }
}
