import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/loan_draft.dart';
import '../../domain/entities/loan_request.dart';
import '../../domain/entities/loan_result.dart';
import '../../domain/repositories/loan_repository.dart';
import '../datasources/loan_local_datasource.dart';
import '../datasources/loan_remote_datasource.dart';

/// Concrete [LoanRepository] handling online submit, offline queue and retry.
///
/// Idempotency strategy: each pending record carries the request's
/// [LoanRequest.idempotencyKey] and a `submitted` flag. [retryPending]
/// persists that flag immediately after each successful POST, so a request is
/// created **exactly once** even if the app is killed mid-flush.
class LoanRepositoryImpl implements LoanRepository {
  const LoanRepositoryImpl({
    required this._remote,
    required this._local,
    required this._networkInfo,
  });

  final LoanRemoteDataSource _remote;
  final LoanLocalDataSource _local;
  final NetworkInfo _networkInfo;

  static const String _keyField = 'key';
  static const String _payloadField = 'payload';
  static const String _submittedField = 'submitted';

  @override
  Future<LoanResult> submit(LoanRequest request) async {
    if (await _networkInfo.isConnected) {
      try {
        final created = await _remote.submitLoan(request.toPayload());
        await clearDraft();
        return LoanResult(
          request: request,
          status: LoanStatus.created,
          id: created['id']?.toString(),
          createdAt: created['createdAt']?.toString(),
        );
      } on NetworkException {
        // Lost connectivity between the check and the call: queue it.
        return _queuePending(request);
      } on ServerException catch (e) {
        // A real rejection is an error the user should see, not a silent queue.
        throw ServerFailure(e.message, e.statusCode ?? 502);
      }
    }
    return _queuePending(request);
  }

  /// Stores [request] as a pending record and returns a pending result.
  Future<LoanResult> _queuePending(LoanRequest request) async {
    final records = _local.readPending();
    // Guard against enqueuing the same request twice (idempotency key).
    final alreadyQueued =
        records.any((r) => r[_keyField] == request.idempotencyKey);
    if (!alreadyQueued) {
      records.add({
        _keyField: request.idempotencyKey,
        _payloadField: request.toPayload(),
        _submittedField: false,
      });
      await _local.writePending(records);
    }
    await clearDraft();
    return LoanResult(request: request, status: LoanStatus.pendingOffline);
  }

  @override
  Future<int> retryPending() async {
    final records = _local.readPending();
    if (records.isEmpty) return 0;

    var created = 0;
    for (final record in records) {
      if (record[_submittedField] == true) continue;
      if (!await _networkInfo.isConnected) break;

      try {
        final payload =
            Map<String, dynamic>.from(record[_payloadField] as Map);
        await _remote.submitLoan(payload);
        record[_submittedField] = true;
        // Persist the flag immediately so a crash can't cause a double POST.
        await _local.writePending(records);
        created++;
      } on NetworkException {
        break; // Connectivity dropped; keep the rest for the next attempt.
      } on ServerException {
        // Attempted once and rejected: mark done so we don't loop forever.
        record[_submittedField] = true;
        await _local.writePending(records);
      }
    }

    // Drop everything that has now been attempted, keep the rest queued.
    final remaining =
        records.where((r) => r[_submittedField] != true).toList();
    await _local.writePending(remaining);
    return created;
  }

  @override
  int pendingCount() =>
      _local.readPending().where((r) => r[_submittedField] != true).length;

  @override
  Future<void> saveDraft(LoanDraft draft) => _local.saveDraft(draft.toJson());

  @override
  LoanDraft? loadDraft() {
    final json = _local.loadDraft();
    return json == null ? null : LoanDraft.fromJson(json);
  }

  @override
  Future<void> clearDraft() => _local.clearDraft();
}
