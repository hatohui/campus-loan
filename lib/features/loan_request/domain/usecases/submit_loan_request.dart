import '../entities/loan_request.dart';
import '../entities/loan_result.dart';
import '../repositories/loan_repository.dart';

/// Use case: submit a validated loan request (online POST or offline queue).
class SubmitLoanRequest {
  const SubmitLoanRequest(this._repository);

  final LoanRepository _repository;

  Future<LoanResult> call(LoanRequest request) => _repository.submit(request);
}
