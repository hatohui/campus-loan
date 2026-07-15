import 'package:intl/intl.dart';

/// Shared display formatters so currency and dates render identically
/// everywhere in the UI (DRY). Missing values render as an em dash.
class Formatters {
  const Formatters._();

  static final NumberFormat _currency =
      NumberFormat.currency(symbol: r'$', decimalDigits: 0);
  static final DateFormat _date = DateFormat('MMM d, yyyy');

  /// Formats an optional price; returns '—' when unknown.
  static String price(num? value) =>
      value == null ? '—' : _currency.format(value);

  /// Formats a deposit amount (always known).
  static String money(num value) => _currency.format(value);

  /// Formats an optional date; returns '—' when unset.
  static String date(DateTime? value) =>
      value == null ? '—' : _date.format(value);
}
