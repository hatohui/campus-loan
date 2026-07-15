import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/compare_provider.dart';

/// Bottom bar summarising the comparison selection (CR#2).
///
/// Hidden entirely when nothing is selected. Shows the current count against
/// the two-item cap and offers a clear action.
class CompareBar extends ConsumerWidget {
  const CompareBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(compareProvider);
    if (selected.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.secondaryContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.compare_arrows, color: scheme.onSecondaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Comparing ${selected.length} of ${AppConstants.maxCompareItems} devices',
                  style: TextStyle(color: scheme.onSecondaryContainer),
                ),
              ),
              TextButton(
                onPressed: ref.read(compareProvider.notifier).clear,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
