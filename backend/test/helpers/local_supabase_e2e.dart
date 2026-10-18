const localSupabaseE2e = bool.fromEnvironment('SUPABASE_LOCAL_E2E');
const localSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const localSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void requireLocalSupabaseE2e() {
  final uri = Uri.tryParse(localSupabaseUrl);
  if (!localSupabaseE2e ||
      localSupabaseAnonKey.isEmpty ||
      uri == null ||
      uri.scheme != 'http' ||
      uri.host != '127.0.0.1' ||
      uri.port != 54421) {
    throw StateError('local_supabase_e2e_configuration_required');
  }
}
