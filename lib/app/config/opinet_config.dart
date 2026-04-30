class OpinetConfig {
  OpinetConfig._();

  static const String apiKey = String.fromEnvironment(
    'OPINET_API_KEY',
    defaultValue: '',
  );

  static bool get isConfigured => apiKey.isNotEmpty;
}
