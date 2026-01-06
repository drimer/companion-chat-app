class ApiConfig {
  ApiConfig._();

  static final String baseUrl = const String.fromEnvironment('API_BASE_URL');

  static void ensureConfigured() {
    if (baseUrl.isEmpty) {
      throw StateError(
        'Missing API_BASE_URL. Provide it via --dart-define or env/settings.env.',
      );
    }
  }
}
