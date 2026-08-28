import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('visual literals stay centralized in the theme layer', () {
    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      if (entity.path.contains(
        '${Platform.pathSeparator}theme${Platform.pathSeparator}',
      )) {
        continue;
      }
      final source = entity.readAsStringSync();
      if (RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)').hasMatch(source)) {
        offenders.add(entity.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Los colores deben provenir de AgroColors: $offenders',
    );
  });
}
