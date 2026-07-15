import '../../../../core/utils/date_validators.dart';

/// Use case that owns the loan-period business rule (CR#3).
///
/// This is the single domain entry point the presentation layer calls to
/// validate dates. It delegates to the pure [LoanPeriodValidator] so the rule
/// itself stays testable in isolation, while giving the UI a use-case-shaped
/// dependency (answering "which domain rule validates the dates?").
class ValidateLoanPeriod {
  const ValidateLoanPeriod();

  LoanPeriodResult call({
    required DateTime borrowDate,
    required DateTime returnDate,
    DateTime? now,
  }) {
    return LoanPeriodValidator.validate(
      borrowDate: borrowDate,
      returnDate: returnDate,
      now: now,
    );
  }
}
