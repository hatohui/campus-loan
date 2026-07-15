import '../constants/app_constants.dart';

/// Pure implementation of the "$50 / $20" deposit rule.
///
/// Kept as a stand-alone pure function (no I/O, no state) so it is the single
/// source of truth shared by the catalogue card, the loan form's deposit
/// summary and the unit tests. The missing-price case is handled here exactly
/// once, guaranteeing the UI and the sort logic agree.
class DepositCalculator {
  const DepositCalculator._();

  /// Returns the estimated deposit for a device given its (possibly unknown)
  /// [price].
  ///
  /// Rules:
  /// - `price == null` (unknown price) -> [AppConstants.standardDeposit].
  /// - `price >= AppConstants.highValueThreshold` -> [AppConstants.highDeposit].
  /// - otherwise -> [AppConstants.standardDeposit].
  static double estimate(num? price) {
    if (price == null) return AppConstants.standardDeposit;
    return price >= AppConstants.highValueThreshold
        ? AppConstants.highDeposit
        : AppConstants.standardDeposit;
  }
}
