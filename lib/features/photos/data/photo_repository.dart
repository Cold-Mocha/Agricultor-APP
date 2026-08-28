import 'dart:io';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/files/private_file_store.dart';
import 'package:agrocampo/features/photos/domain/photo_attachment.dart';
import 'package:agrocampo/shared/domain/entity_id.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;

abstract interface class PhotoUploadGateway {
  Future<String> upload({
    required String ownerId,
    required String contentHash,
    required String mimeType,
    required List<int> bytes,
  });
}

final class PhotoRepository {
  PhotoRepository(this._database, this._fileStore);

  final AppDatabase _database;
  final FileStore _fileStore;

  Future<String> attach(PhotoAttachmentInput input) async {
    final bytes = await File(input.sourcePath).readAsBytes();
    final hash = sha256.convert(bytes).toString();
    final duplicate =
        await (_database.select(_database.photoAttachments)..where(
              (row) =>
                  row.ownerId.equals(input.ownerId) &
                  row.contentHash.equals(hash),
            ))
            .getSingleOrNull();
    if (duplicate != null) return duplicate.id;
    final id = EntityId.generate().value;
    final extension = path.extension(input.sourcePath).toLowerCase();
    final localPath = await _fileStore.import(
      input.sourcePath,
      input.ownerId,
      '$hash$extension',
    );
    await _database
        .into(_database.photoAttachments)
        .insert(
          PhotoAttachmentsCompanion.insert(
            id: id,
            ownerId: input.ownerId,
            aggregateType: input.aggregateType,
            aggregateId: input.aggregateId,
            localPath: localPath,
            contentHash: hash,
            mimeType: input.mimeType,
            capturedAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }

  Future<void> uploadPending(String ownerId, PhotoUploadGateway gateway) async {
    final pending =
        await (_database.select(_database.photoAttachments)..where(
              (row) =>
                  row.ownerId.equals(ownerId) &
                  row.uploadState.equals('pending'),
            ))
            .get();
    for (final photo in pending) {
      final remotePath = await gateway.upload(
        ownerId: ownerId,
        contentHash: photo.contentHash,
        mimeType: photo.mimeType,
        bytes: await File(photo.localPath).readAsBytes(),
      );
      await (_database.update(
        _database.photoAttachments,
      )..where((row) => row.id.equals(photo.id))).write(
        PhotoAttachmentsCompanion(
          remotePath: Value(remotePath),
          uploadState: const Value('done'),
        ),
      );
    }
  }
}
