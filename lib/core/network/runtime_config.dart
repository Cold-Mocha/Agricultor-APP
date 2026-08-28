import 'package:agrocampo/app/bootstrap/app_environment.dart';

final class RuntimeConfig {
  const RuntimeConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
  });

  factory RuntimeConfig.fromCompileTime() {
    final environment = AppEnvironmentConfig.fromCompileTime();
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (environment.isProduction && (url.isEmpty || key.isEmpty)) {
      throw const FormatException(
        'Falta configuración pública de Supabase para producción.',
      );
    }
    return RuntimeConfig(
      environment: environment,
      supabaseUrl: url,
      supabasePublishableKey: key,
    );
  }

  final AppEnvironmentConfig environment;
  final String supabaseUrl;
  final String supabasePublishableKey;

  bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
