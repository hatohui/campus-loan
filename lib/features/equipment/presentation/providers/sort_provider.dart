import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The available catalogue sort orders (CR#4).
///
/// [apiOrder] is the default and preserves the original response order; the
/// other two are derived views that never mutate the source list.
enum SortOption {
  apiOrder('Default (API order)'),
  depositLowHigh('Deposit: Low to High'),
  nameAZ('Name: A to Z');

  const SortOption(this.label);

  final String label;
}

/// Holds the currently selected [SortOption].
class SortNotifier extends Notifier<SortOption> {
  @override
  SortOption build() => SortOption.apiOrder;

  void select(SortOption option) => state = option;
}

final sortProvider =
    NotifierProvider<SortNotifier, SortOption>(SortNotifier.new);
