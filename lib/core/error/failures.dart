/// Domain-level failures surfaced to the presentation layer.
///
/// Every failure carries a stable machine-readable [code] and a user-safe
/// [message]. The presentation layer renders [message] and never sees a raw
/// stack trace, satisfying the "no leaked stack traces" rule.
library;

/// Standardised, serialisable error payload: `{ status, message, code }`.
typedef ErrorPayload = Map<String, Object?>;

/// Base type for all recoverable failures in the app.
sealed class Failure implements Exception {
  const Failure(this.message, this.code);

  /// Human-readable, user-safe description of what went wrong.
  final String message;

  /// Stable error code used for logging, tests and standardised payloads.
  final int code;

  /// Standardised error payload as mandated by the project rules.
  ErrorPayload toPayload() => {
        'status': 'error',
        'message': message,
        'code': code,
      };

  @override
  String toString() => 'Failure($code): $message';
}

/// The remote server returned an error response.
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'The server could not process the request.',
    super.code = 502,
  ]);
}

/// The device is offline and no cached fallback was available.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'You appear to be offline.',
    super.code = 503,
  ]);
}

/// A local cache read failed or returned nothing usable.
class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'No cached data available.',
    super.code = 404,
  ]);
}

/// User input failed a domain validation rule.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code = 422]);
}
