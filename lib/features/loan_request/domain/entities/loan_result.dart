import 'loan_request.dart';

/// Where a submitted request ended up.
enum LoanStatus {
  /// Successfully created on the server (has an id + createdAt).
  created,

  /// Saved locally because the app was offline; awaiting retry.
  pendingOffline,
}

/// Outcome of submitting a [LoanRequest], used to build the result screen (D).
///
/// For an online submission [id] and [createdAt] come straight from the POST
/// response — which the spec names as the sole success criterion. For an
/// offline submission both are null and [status] is [LoanStatus.pendingOffline].
class LoanResult {
  const LoanResult({
    required this.request,
    required this.status,
    this.id,
    this.createdAt,
  });

  /// Echo of the submitted request (dates, deposit, etc. for display).
  final LoanRequest request;

  final LoanStatus status;

  /// Server-assigned id, present only when [status] is [LoanStatus.created].
  final String? id;

  /// Server timestamp, present only when [status] is [LoanStatus.created].
  final String? createdAt;

  bool get isCreated => status == LoanStatus.created;
}
