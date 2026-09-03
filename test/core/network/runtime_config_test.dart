import 'package:agrocampo/app/bootstrap/app_environment.dart';
import 'package:agrocampo/core/network/runtime_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compile-time runtime configuration is internally consistent', () {
    final config = RuntimeConfig.fromCompileTime();

    if (config.environment.environment == AppEnvironment.production) {
      expect(config.hasSupabase, isTrue);
      expect(Uri.parse(config.supabaseUrl).scheme, 'https');
      expect(config.supabasePublishableKey, startsWith('sb_publishable_'));
    } else {
      expect(
        config.hasSupabase,
        config.supabaseUrl.isNotEmpty &&
            config.supabasePublishableKey.isNotEmpty,
      );
    }
  });
}
