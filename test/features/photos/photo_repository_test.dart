import 'dart:io';

import 'package:agrocampo/core/files/private_file_store.dart';
import 'package:agrocampo/features/photos/data/photo_repository.dart';
import 'package:agrocampo/features/photos/domain/photo_attachment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';

final class _TestFileStore implements FileStore {
  _TestFileStore(this.directory);

  final Directory directory;

  @override
  Future<String> import(
    String sourcePath,
    String ownerId,
    String fileName,
  ) async {
    final destination = '${directory.path}/$fileName';
    await File(sourcePath).copy(destination);
    return destination;
  }
}

final class _UploadGateway implements PhotoUploadGateway {
  int calls = 0;

  @override
  Future<String> upload({
    required String ownerId,
    required String contentHash,
    required String mimeType,
    required List<int> bytes,
  }) async {
    calls += 1;
    return '$ownerId/$contentHash';
  }
}

void main() {
  test('deduplicates identical content and uploads it once', () async {
    final database = createInMemoryDatabase();
    final directory = await Directory.systemTemp.createTemp('agrocampo-photo');
    addTearDown(database.close);
    addTearDown(() => directory.delete(recursive: true));
    final source = File('${directory.path}/capture.jpg');
    await source.writeAsBytes([1, 2, 3, 4]);
    final repository = PhotoRepository(database, _TestFileStore(directory));
    final input = PhotoAttachmentInput(
      ownerId: 'owner-1',
      aggregateType: 'sector',
      aggregateId: 'sector-1',
      sourcePath: source.path,
      mimeType: 'image/jpeg',
    );

    final first = await repository.attach(input);
    final duplicate = await repository.attach(input);
    final gateway = _UploadGateway();
    await repository.uploadPending('owner-1', gateway);

    expect(duplicate, first);
    expect(
      await database.select(database.photoAttachments).get(),
      hasLength(1),
    );
    expect(gateway.calls, 1);
    expect(
      (await database.select(database.photoAttachments).getSingle())
          .uploadState,
      'done',
    );
  });
}
