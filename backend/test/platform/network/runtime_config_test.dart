import 'package:agrocampo_backend/src/composition/app_environment.dart';
import 'package:agrocampo_backend/src/platform/network/runtime_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const environment = AppEnvironmentConfig(
    environment: AppEnvironment.development,
  );

  test('online build with Supabase values uses Supabase', () {
    const config = RuntimeConfig(
      environment: environment,
      supabaseUrl: 'https://example.supabase.co',
      supabasePublishableKey: 'sb_publishable_test',
    );

    expect(config.online, isTrue);
    expect(config.hasSupabase, isTrue);
  });

  test('local build never uses Supabase even when values are present', () {
    const config = RuntimeConfig(
      environment: environment,
      supabaseUrl: 'https://example.supabase.co',
      supabasePublishableKey: 'sb_publishable_test',
      online: false,
    );

    expect(config.hasSupabase, isFalse);
  });
}
