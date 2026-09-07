import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public exports do not expose infrastructure libraries', () {
    final seen = <String>{};
    final violations = <String>[];
    void inspect(File file) {
      final normalized = file.absolute.path.replaceAll('\\', '/');
      if (!seen.add(normalized)) return;
      final source = file.readAsStringSync();
      for (final match in RegExp(
        r'''export\s+['"]([^'"]+)['"]''',
      ).allMatches(source)) {
        final uri = match.group(1)!;
        if (uri.startsWith('package:') || uri.startsWith('dart:')) {
          violations.add('${file.path}: exported external implementation $uri');
          continue;
        }
        final target = File.fromUri(file.absolute.uri.resolve(uri));
        final path = target.path.replaceAll('\\', '/');
        if (path.contains('/repositories/') ||
            RegExp(
              r'/core/(database|sync|auth|files|network|notifications|export)/',
            ).hasMatch(path)) {
          violations.add(path);
        } else {
          inspect(target);
        }
      }
    }

    inspect(File('../backend/lib/agrocampo_backend.dart'));
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('presentation uses only the public backend contract', () {
    final violations = <String>[];
    final imports = RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''');
    const infrastructurePackages = {
      'drift',
      'drift_flutter',
      'supabase_flutter',
      'supabase',
      'sqlite3',
      'flutter_secure_storage',
      'path_provider',
      'workmanager',
      'flutter_local_notifications',
      'image_picker',
      'geolocator',
      'firebase_core',
      'firebase_messaging',
      'local_auth',
      'excel',
    };
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      for (final match in imports.allMatches(source)) {
        final uri = match.group(1)!;
        if ((uri.startsWith('package:agrocampo_backend/') &&
                uri != 'package:agrocampo_backend/agrocampo_backend.dart') ||
            uri.contains('backend/lib/') ||
            infrastructurePackages.any(
              (name) => uri.startsWith('package:$name/'),
            )) {
          violations.add('${file.path}: $uri');
        }
      }
      if (RegExp(
        r'\b(AppDatabase|SupabaseClient|appDatabaseProvider|supabaseClientProvider|[A-Z]\w*Companion)\b',
      ).hasMatch(source)) {
        violations.add('${file.path}: persistence detail in presentation');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('backend cannot depend on frontend or render widgets', () {
    final violations = <String>[];
    for (final file in Directory(
      '../backend/lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      if (source.contains('package:agrocampo/') ||
          RegExp(r'''package:flutter/(material|cupertino|widgets)\.dart''')
              .hasMatch(source) ||
          source.contains('package:go_router/')) {
        violations.add(file.path);
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
    expect(
      Directory('../lib').existsSync(),
      isFalse,
      reason: 'The repository must have only frontend and backend production packages.',
    );
  });
}
