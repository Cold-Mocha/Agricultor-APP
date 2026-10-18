import 'dart:async';

import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/media/domain/entities/photo_attachment.dart';
import 'package:agrocampo_backend/src/modules/media/infrastructure/persistence/photo_repository.dart';
import 'package:agrocampo_backend/src/modules/media/infrastructure/persistence/supabase_photo_gateway.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/files/private_file_store.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mediaFacadeProvider = Provider<MediaFacade>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MediaFacade(
    ref.watch(appDatabaseProvider),
    PrivateFileStore(),
    client == null ? null : SupabasePhotoGateway(client),
    (ownerId) => ref.read(syncSchedulerProvider).schedule(ownerId: ownerId),
  );
});

final class MediaFacade {
  MediaFacade(this._database, this._fileStore, [this._upload, this._retry]);
  final AppDatabase _database;
  final PrivateFileStore _fileStore;
  final PhotoUploadGateway? _upload;
  final Future<void> Function(String ownerId)? _retry;

  Future<bool> attach({
    required String ownerId,
    required String sectorId,
    required String sourcePath,
    required String mimeType,
    String? laborId,
  }) async {
    final sector =
        await (_database.select(_database.sectors)..where(
              (row) => row.ownerId.equals(ownerId) & row.id.equals(sectorId),
            ))
            .getSingleOrNull();
    if (sector == null) return false;
    await PhotoRepository(_database, _fileStore).attach(
      PhotoAttachmentInput(
        ownerId: ownerId,
        aggregateType: laborId == null ? 'sector' : 'labor',
        aggregateId: laborId ?? sector.id,
        sourcePath: sourcePath,
        mimeType: mimeType,
      ),
    );
    unawaited(_uploadAfterAttach(ownerId));
    return true;
  }

  Future<void> _uploadAfterAttach(String ownerId) async {
    if (await uploadPending(ownerId)) return;
    try {
      await _retry?.call(ownerId);
    } on Object {
      // Local attachment remains valid; resume/connectivity retries it too.
    }
  }

  Future<bool> uploadPending(String ownerId) async {
    final gateway = _upload;
    if (gateway == null) return true;
    try {
      return await PhotoRepository(
        _database,
        _fileStore,
      ).uploadPending(ownerId, gateway);
    } on Object {
      return false;
    }
  }
}
