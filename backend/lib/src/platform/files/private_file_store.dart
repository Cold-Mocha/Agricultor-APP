import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

abstract interface class FileStore {
  Future<String> import(String sourcePath, String ownerId, String fileName);
}

final class PrivateFileStore implements FileStore {
  @override
  Future<String> import(
    String sourcePath,
    String ownerId,
    String fileName,
  ) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(path.join(root.path, 'photos', ownerId));
    await directory.create(recursive: true);
    final destination = path.join(directory.path, fileName);
    await File(sourcePath).copy(destination);
    return destination;
  }
}
