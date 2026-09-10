import 'dart:io';

import 'package:agrocampo_backend/src/modules/media/domain/entities/photo_attachment.dart';
import 'package:agrocampo_backend/src/modules/media/infrastructure/persistence/photo_repository.dart';
import 'package:agrocampo_backend/src/platform/files/private_file_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

final class _Store implements FileStore {
  _Store(this.directory);
  final Directory directory;
  @override
  Future<String> import(String sourcePath, String ownerId, String fileName) async {
    final target = '${directory.path}/$fileName';
    await File(sourcePath).copy(target);
    return target;
  }
}

void main() {
  test('apiary photo targets the confirmed labor and enforces owner isolation', () async {
    final database = createInMemoryDatabase();
    final directory = await Directory.systemTemp.createTemp('agrocampo-apiary-photo');
    addTearDown(database.close);
    addTearDown(() => directory.delete(recursive: true));
    await seedTerritoryFixture(database);
    await database.customUpdate(
      "INSERT INTO labors (id, owner_id, parcel_id, sector_id, type, occurred_at, updated_at) VALUES ('apiary-labor','owner-1','parcel-1','sector-1','apiary',?,?)",
      variables: [
        Variable<DateTime>(DateTime.utc(2026)),
        Variable<DateTime>(DateTime.utc(2026)),
      ],
    );
    final source = File('${directory.path}/capture.jpg')..writeAsBytesSync([1, 2, 3]);
    final repository = PhotoRepository(database, _Store(directory));
    final photoId = await repository.attach(PhotoAttachmentInput(
      ownerId: 'owner-1',
      aggregateType: 'labor',
      aggregateId: 'apiary-labor',
      sourcePath: source.path,
      mimeType: 'image/jpeg',
    ));
    expect(photoId, isNotEmpty);
    expect((await database.select(database.photoAttachments).getSingle()).aggregateId, 'apiary-labor');
    await expectLater(
      repository.attach(PhotoAttachmentInput(
        ownerId: 'owner-2',
        aggregateType: 'labor',
        aggregateId: 'apiary-labor',
        sourcePath: source.path,
        mimeType: 'image/jpeg',
      )),
      throwsStateError,
    );
  });
}
