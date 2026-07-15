/// Low-level exceptions thrown by the data layer (data sources).
///
/// These are intentionally distinct from [Failure] objects: exceptions belong
/// to the data layer, while repositories translate them into domain [Failure]s
/// so the presentation layer never has to reason about transport details.
library;

/// Thrown when the remote API is unreachable or times out.
class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);
  final String message;
}

/// Thrown when the server responds with a non-success status code.
class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

/// Thrown when the local cache is queried but holds no usable data.
class CacheException implements Exception {
  const CacheException([this.message = 'No cached data available']);
  final String message;
}
