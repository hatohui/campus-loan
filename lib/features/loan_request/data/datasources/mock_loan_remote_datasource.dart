import 'loan_remote_datasource.dart';

/// In-memory [LoanRemoteDataSource] used in mock mode.
///
/// Echoes the posted payload back as a "created" object with a generated [id]
/// and [createdAt], mirroring the real API's success response so the result
/// screen (D) behaves identically without a network call.
class MockLoanRemoteDataSource implements LoanRemoteDataSource {
  const MockLoanRemoteDataSource();

  @override
  Future<Map<String, dynamic>> submitLoan(Map<String, dynamic> payload) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return {
      'id': 'mock-${now.millisecondsSinceEpoch}',
      'name': payload['name'],
      'data': payload['data'],
      'createdAt': now.toUtc().toIso8601String(),
    };
  }
}
