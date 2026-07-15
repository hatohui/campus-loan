import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sort_provider.dart';

/// App-bar action that lets the user pick a [SortOption] (CR#4).
///
/// It only reads/writes the [sortProvider]; the actual reordering is a pure
/// derivation in `filteredDevicesProvider`, so this widget stays declarative.
class SortMenu extends ConsumerWidget {
  const SortMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sortProvider);
    return PopupMenuButton<SortOption>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort devices',
      initialValue: current,
      onSelected: ref.read(sortProvider.notifier).select,
      itemBuilder: (context) => [
        for (final option in SortOption.values)
          PopupMenuItem<SortOption>(
            value: option,
            child: Row(
              children: [
                Icon(
                  option == current
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Text(option.label),
              ],
            ),
          ),
      ],
    );
  }
}
