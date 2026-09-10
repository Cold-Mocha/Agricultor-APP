enum AppEnvironment { development, staging, production }

final class AppEnvironmentConfig {
  const AppEnvironmentConfig({required this.environment});

  factory AppEnvironmentConfig.fromCompileTime() {
    const value = String.fromEnvironment(
      'AGROCAMPO_ENV',
      defaultValue: 'development',
    );
    return AppEnvironmentConfig(
      environment: AppEnvironment.values.firstWhere(
        (item) => item.name == value,
        orElse: () => AppEnvironment.development,
      ),
    );
  }

  final AppEnvironment environment;

  bool get isProduction => environment == AppEnvironment.production;
}
