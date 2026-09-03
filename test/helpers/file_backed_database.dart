import 'dart:io';

import 'package:agrocampo/core/database/app_database.dart';
import 'package:drift/native.dart';

final class FileBackedDatabaseFixture {
  FileBackedDatabaseFixture._(this.directory, this.databaseFile);

  final Directory directory;
  final File databaseFile;

  static Future<FileBackedDatabaseFixture> create() async {
    final directory = await Directory.systemTemp.createTemp('agrocampo-drift-');
    return FileBackedDatabaseFixture._(
      directory,
      File('${directory.path}${Platform.pathSeparator}agrocampo.sqlite'),
    );
  }

  AppDatabase open() => AppDatabase.forTesting(NativeDatabase(databaseFile));

  Future<void> dispose() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
