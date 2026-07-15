/// Compile-time app configuration sourced from `--dart-define` values.
///
/// Secrets (like the RESTful API key) are read from the environment rather than
/// hard-coded, satisfying the "never hardcode secrets" rule. Pass them at run
/// time, e.g. `flutter run --dart-define=API_KEY=xxxxxxxx`.
class AppConfig {
  const AppConfig._();

  /// API key sent as the `x-api-key` header to lift the public rate limit.
  /// Empty when unset, in which case requests are made unauthenticated.
  static const String apiKey = String.fromEnvironment('API_KEY');

  static bool get hasApiKey => apiKey.isNotEmpty;

  /// When true, the app talks to in-memory mock data sources instead of the
  /// live REST API. Useful for demos when the public API is rate-limited.
  /// Enable with `--dart-define=MOCK_API=true`. Defaults to the real API.
  static const bool useMockApi =
      bool.fromEnvironment('MOCK_API', defaultValue: false);
}
