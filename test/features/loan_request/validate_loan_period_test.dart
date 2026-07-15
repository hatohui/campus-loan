import 'package:flutter_application_1/features/loan_request/domain/usecases/validate_loan_period.dart';
import 'package:flutter_test/flutter_test.dart';

/// Confirms the domain use case wires the loan-period rule through correctly.
void main() {
  const usecase = ValidateLoanPeriod();
  final now = DateTime(2026, 8, 1);

  test('valid period passes through the use case', () {
    final result = usecase(
      borrowDate: DateTime(2026, 8, 2),
      returnDate: DateTime(2026, 8, 6),
      now: now,
    );
    expect(result.isValid, isTrue);
  });

  test('past borrow date is rejected by the use case', () {
    final result = usecase(
      borrowDate: DateTime(2026, 7, 20),
      returnDate: DateTime(2026, 7, 25),
      now: now,
    );
    expect(result.isValid, isFalse);
  });
}
