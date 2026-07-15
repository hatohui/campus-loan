import '../repositories/loan_repository.dart';

/// Use case: flush the offline queue, retrying each pending request once.
class RetryPendingRequests {
  const RetryPendingRequests(this._repository);

  final LoanRepository _repository;

  Future<int> call() => _repository.retryPending();
}
