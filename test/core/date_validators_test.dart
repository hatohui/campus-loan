import 'package:flutter_application_1/core/utils/date_validators.dart';
import 'package:flutter_test/flutter_test.dart';

/// Part 4 — unit test for past dates, reversed dates and the 14-day maximum.
void main() {
  // Fixed "today" so the tests are deterministic regardless of wall clock.
  final now = DateTime(2026, 8, 1);

  LoanPeriodResult validate(DateTime borrow, DateTime ret) =>
      LoanPeriodValidator.validate(
        borrowDate: borrow,
        returnDate: ret,
        now: now,
      );

  group('LoanPeriodValidator.validate', () {
    test('rejects a borrow date in the past', () {
      final result = validate(DateTime(2026, 7, 31), DateTime(2026, 8, 3));
      expect(result.isValid, isFalse);
      expect(result.error, contains('past'));
    });

    test('rejects a return date that is not after the borrow date', () {
      final same = validate(DateTime(2026, 8, 5), DateTime(2026, 8, 5));
      expect(same.isValid, isFalse);
      expect(same.error, contains('after'));

      final reversed = validate(DateTime(2026, 8, 5), DateTime(2026, 8, 2));
      expect(reversed.isValid, isFalse);
    });

    test('rejects a period longer than 14 days', () {
      final result = validate(DateTime(2026, 8, 1), DateTime(2026, 8, 16));
      expect(result.isValid, isFalse);
      expect(result.error, contains('14'));
    });

    test('accepts a valid period, including exactly 14 days', () {
      expect(validate(DateTime(2026, 8, 1), DateTime(2026, 8, 8)).isValid,
          isTrue);
      expect(validate(DateTime(2026, 8, 1), DateTime(2026, 8, 15)).isValid,
          isTrue);
    });
  });
}
