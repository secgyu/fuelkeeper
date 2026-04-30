class KakaoConfig {
  KakaoConfig._();

  static const String restApiKey = String.fromEnvironment(
    'KAKAO_REST_API_KEY',
    defaultValue: '',
  );

  static bool get isConfigured => restApiKey.isNotEmpty;
}
