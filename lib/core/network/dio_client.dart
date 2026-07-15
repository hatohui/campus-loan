import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_constants.dart';

/// Thin factory that builds a pre-configured [Dio] instance.
///
/// Centralising Dio construction guarantees every request shares the same base
/// URL, timeouts and JSON headers, and gives a single seam where tests can
/// inject a mock [HttpClientAdapter] instead of hitting the live network.
class DioClient {
  const DioClient._();

  /// Creates the app's HTTP client with sane production defaults.
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.timeout,
        receiveTimeout: ApiConstants.timeout,
        sendTimeout: ApiConstants.timeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        // Authenticate when an API key is provided, lifting the public
        // rate limit. Omitted entirely when unset (no hard-coded secret).
        headers: AppConfig.hasApiKey
            ? {'x-api-key': AppConfig.apiKey}
            : null,
      ),
    );

    // Treat only 2xx as success so the repository layer can rely on thrown
    // DioExceptions for every non-success response.
    dio.options.validateStatus = (status) => status != null && status < 300;

    return dio;
  }
}
