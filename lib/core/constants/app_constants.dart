/// Business constants that encode the exam's domain rules in one auditable place.
///
/// Centralising these values means the deposit tiers and loan-period limit are
/// defined exactly once and reused by the calculator, validators and tests, so
/// the rules cannot silently drift apart between UI and domain layers.
class AppConstants {
  const AppConstants._();

  // --- Deposit rule ($50 / $20) ------------------------------------------

  /// Price (inclusive) at or above which a device is treated as high value.
  static const num highValueThreshold = 500;

  /// Deposit charged for high-value devices (price >= [highValueThreshold]).
  static const double highDeposit = 50;

  /// Deposit charged for standard devices and for devices with no known price.
  static const double standardDeposit = 20;

  // --- Loan-period rule ---------------------------------------------------

  /// Maximum number of days a device may be borrowed for (inclusive).
  static const int maxLoanDays = 14;

  // --- Change-request tuning ---------------------------------------------

  /// Debounce window applied to the catalogue search box (CR#1).
  static const Duration searchDebounce = Duration(milliseconds: 400);

  /// Maximum number of devices allowed in the comparison list (CR#2).
  static const int maxCompareItems = 2;
}
