import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('frontend uses only the backend public barrel and no parallel 003 module', () {
    final root = Directory.current.parent;
    final lib = Directory('${root.path}/frontend/lib');
    final forbidden = <String>[];
    for (final entity in lib.listSync(recursive: true).whereType<File>()) {
      if (!entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      for (final line in source.split('\n')) {
        if (line.contains('package:agrocampo_backend/') &&
            !line.contains('package:agrocampo_backend/agrocampo_backend.dart')) {
          forbidden.add('${entity.path}: $line');
        }
      }
    }
    expect(forbidden, isEmpty);
    expect(
      Directory('${root.path}/frontend/lib/src/modules/003').existsSync(),
      isFalse,
    );
    expect(
      Directory('${root.path}/backend/lib/src/modules/003').existsSync(),
      isFalse,
    );
  });
}
