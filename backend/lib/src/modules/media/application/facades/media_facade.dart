import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/media/domain/entities/photo_attachment.dart';
import 'package:agrocampo_backend/src/modules/media/infrastructure/persistence/photo_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:agrocampo_backend/src/platform/files/private_file_store.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mediaFacadeProvider = Provider<MediaFacade>(
  (ref) => MediaFacade(ref.watch(appDatabaseProvider), PrivateFileStore()),
);

final class MediaFacade {
  MediaFacade(this._database, this._fileStore);
  final AppDatabase _database;
  final PrivateFileStore _fileStore;

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
    return true;
  }
}
