// Reinforces the deployment pipeline: proves that RuntimeConfig.fromCompileTime()
// (backend/lib/src/platform/network/runtime_config.dart) still fails closed for an
// unconfigured production build instead of silently shipping without Supabase.
//
// Usage (compile-time defines mirror the Flutter --dart-define contract):
//   dart run backend/tool/verify_runtime_config_guard.dart
//     -> development default, must resolve without Supabase configured.
//   dart run -DAGROCAMPO_ENV=production backend/tool/verify_runtime_config_guard.dart
//     -> must exit 1 (refused) unless SUPABASE_URL/SUPABASE_PUBLISHABLE_KEY are
//        also passed. CI (.github/workflows/ci.yml) asserts both branches on every
//        push so a future edit cannot silently weaken this guard.
import 'dart:io';

import 'package:agrocampo_backend/src/platform/network/runtime_config.dart';

void main() {
  try {
    final config = RuntimeConfig.fromCompileTime();
    stdout.writeln(
      'RuntimeConfig resolved: '
      'environment=${config.environment.environment.name} '
      'hasSupabase=${config.hasSupabase}',
    );
    exitCode = 0;
  } on FormatException catch (error) {
    stdout.writeln('RuntimeConfig refused to resolve: ${error.message}');
    exitCode = 1;
  }
}
