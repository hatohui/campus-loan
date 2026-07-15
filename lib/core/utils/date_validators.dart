import '../constants/app_constants.dart';

/// Outcome of validating a loan period. `null` [error] means the period is valid.
class LoanPeriodResult {
  const LoanPeriodResult(this.error);

  /// A user-safe message describing the first broken rule, or `null` if valid.
  final String? error;

  bool get isValid => error == null;

  static const LoanPeriodResult valid = LoanPeriodResult(null);
}

/// Pure validator for the loan-period rules (CR#3).
///
/// All three rules live here so the domain use case and the widget can share
/// one implementation, and so the unit tests can exercise past / reversed /
/// over-limit dates without any UI or clock dependency (via the injectable
/// [now] parameter).
class LoanPeriodValidator {
  const LoanPeriodValidator._();

  /// Validates that:
  /// 1. [borrowDate] is not before today (no past borrow dates),
  /// 2. [returnDate] is strictly after [borrowDate],
  /// 3. the inclusive period does not exceed [AppConstants.maxLoanDays].
  ///
  /// Comparison is date-only (time-of-day is ignored). [now] is injectable so
  /// tests are deterministic; it defaults to the current wall clock.
  static LoanPeriodResult validate({
    required DateTime borrowDate,
    required DateTime returnDate,
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final borrow = _dateOnly(borrowDate);
    final ret = _dateOnly(returnDate);

    if (borrow.isBefore(today)) {
      return const LoanPeriodResult('Borrow date cannot be in the past.');
    }
    if (!ret.isAfter(borrow)) {
      return const LoanPeriodResult('Return date must be after the borrow date.');
    }
    if (ret.difference(borrow).inDays > AppConstants.maxLoanDays) {
      return const LoanPeriodResult(
        'The loan period cannot exceed ${AppConstants.maxLoanDays} days.',
      );
    }
    return LoanPeriodResult.valid;
  }

  /// Strips the time component so comparisons are purely calendar-based.
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
