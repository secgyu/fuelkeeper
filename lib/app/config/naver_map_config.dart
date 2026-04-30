class NaverMapConfig {
  NaverMapConfig._();

  static const String clientId = String.fromEnvironment(
    'NAVER_MAP_CLIENT_ID',
    defaultValue: '',
  );

  static bool get isConfigured => clientId.isNotEmpty;
}
