/// Central definition of the remote REST endpoints used by the app.
///
/// Keeping these in one place means data sources never hard-code URLs, which
/// makes the network layer trivial to point at a mock server during testing.
class ApiConstants {
  const ApiConstants._();

  /// Base URL of the public RESTful API backing the equipment catalogue.
  static const String baseUrl = 'https://api.restful-api.dev';

  /// Collection endpoint: `GET` lists devices, `POST` creates a loan request.
  static const String objects = '/objects';

  /// Single-resource endpoint template. Callers append the device id.
  static String objectById(String id) => '/objects/$id';

  /// Network timeout applied to every request (connect + receive).
  static const Duration timeout = Duration(seconds: 15);
}
