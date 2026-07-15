import 'package:flutter_application_1/core/constants/app_constants.dart';
import 'package:flutter_application_1/core/utils/deposit_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Part 4 — unit test for the "$50 / $20" deposit rule, including missing price.
void main() {
  group('DepositCalculator.estimate', () {
    test('missing price falls back to the standard deposit', () {
      expect(DepositCalculator.estimate(null), AppConstants.standardDeposit);
    });

    test('price below the high-value threshold is the standard deposit', () {
      expect(DepositCalculator.estimate(100), AppConstants.standardDeposit);
      expect(
        DepositCalculator.estimate(AppConstants.highValueThreshold - 0.01),
        AppConstants.standardDeposit,
      );
    });

    test('price at or above the threshold is the high deposit', () {
      expect(
        DepositCalculator.estimate(AppConstants.highValueThreshold),
        AppConstants.highDeposit,
      );
      expect(DepositCalculator.estimate(1500), AppConstants.highDeposit);
    });
  });
}
