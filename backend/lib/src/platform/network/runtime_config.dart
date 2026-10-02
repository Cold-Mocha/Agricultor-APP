import 'package:agrocampo_backend/src/composition/app_environment.dart';

final class RuntimeConfig {
  const RuntimeConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    this.online = true,
  });

  factory RuntimeConfig.fromCompileTime() {
    final environment = AppEnvironmentConfig.fromCompileTime();
    const online = bool.fromEnvironment('AGROCAMPO_ONLINE', defaultValue: true);
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (online && environment.isProduction && (url.isEmpty || key.isEmpty)) {
      throw const FormatException(
        'Falta configuración pública de Supabase para producción.',
      );
    }
    return RuntimeConfig(
      environment: environment,
      supabaseUrl: url,
      supabasePublishableKey: key,
      online: online,
    );
  }

  final AppEnvironmentConfig environment;
  final String supabaseUrl;
  final String supabasePublishableKey;

  /// False builds a local-only app: no sign-in, no Supabase and no remote
  /// services, even when Supabase values are present.
  final bool online;

  bool get hasSupabase =>
      online && supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
