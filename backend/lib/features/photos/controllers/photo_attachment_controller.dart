import 'dart:typed_data';

import 'package:drift/drift.dart' hide Uint8List;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/backend_providers.dart';
import '../../../core/files/private_file_store.dart';
import '../../auth/controllers/session_controller.dart';
import '../domain/photo_attachment.dart';
import '../repositories/photo_repository.dart';

enum PhotoSelectionSource { camera, gallery }

/// Preview bytes may be rendered by the frontend; the private source stays here.
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
    final ownerId = _ref.read(sessionControllerProvider).ownerId;
    if (ownerId == null) return false;
    final database = _ref.read(appDatabaseProvider);
    final sector =
        await (database.select(database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return false;
    await PhotoRepository(database, PrivateFileStore()).attach(
      PhotoAttachmentInput(
        ownerId: ownerId,
        aggregateType: 'sector',
        aggregateId: sector.id,
        sourcePath: selection._source.path,
        mimeType: selection._source.mimeType ?? 'image/jpeg',
      ),
    );
    return true;
  }
}
