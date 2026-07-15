import '../entities/loan_draft.dart';
import '../entities/loan_request.dart';
import '../entities/loan_result.dart';

/// Domain contract for submitting and persisting loan requests.
abstract interface class LoanRepository {
  /// Submits [request]. When online, POSTs and returns a created [LoanResult];
  /// when offline, stores a pending request and returns a pending [LoanResult].
  /// Throws a [Failure] only when the server actively rejects the request.
  Future<LoanResult> submit(LoanRequest request);

  /// Persists the in-progress form [draft] so it survives an app restart.
  Future<void> saveDraft(LoanDraft draft);

  /// Loads the persisted draft, or `null` if none was saved.
  LoanDraft? loadDraft();

  /// Clears the persisted draft (e.g. after a successful submit).
  Future<void> clearDraft();

  /// Retries every stored pending request exactly once, returning how many
  /// were successfully created. Used when connectivity returns.
  Future<int> retryPending();

  /// How many pending (not-yet-created) requests are queued locally.
  int pendingCount();
}
