import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_filter_provider.dart';

/// Horizontal row of category filter chips (All + each category present in the
/// catalogue). Selecting a chip updates [categoryFilterProvider]; the actual
/// filtering happens in `filteredDevicesProvider`.
class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(availableCategoriesProvider);
    final selected = ref.watch(categoryFilterProvider);
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: 'All',
            selected: selected == null,
            onSelected: () =>
                ref.read(categoryFilterProvider.notifier).select(null),
          ),
          for (final category in categories)
            _Chip(
              label: category.label,
              selected: selected == category,
              onSelected: () =>
                  ref.read(categoryFilterProvider.notifier).select(category),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
      ),
    );
  }
}
