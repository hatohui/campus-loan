import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/device.dart';
import '../providers/compare_provider.dart';
import 'category_icon.dart';

/// Catalogue list item showing a device's key facts and a compare toggle.
///
/// A [ConsumerWidget] so it can reflect and mutate the comparison selection
/// without the parent list rebuilding. Tapping the card opens the detail
/// screen, passing the already-loaded [Device] as router `extra` to avoid a
/// redundant fetch.
class DeviceCard extends ConsumerWidget {
  const DeviceCard({super.key, required this.device});

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedIds = ref.watch(compareProvider);
    final isSelected = selectedIds.contains(device.id);
    final canSelectMore = ref.watch(compareProvider.notifier).isFull == false;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.device(device.id), extra: device),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Icon(iconForCategory(device.category)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: ${Formatters.price(device.price)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text('Dep ${Formatters.money(device.estimatedDeposit)}'),
                  ),
                  IconButton(
                    tooltip: isSelected
                        ? 'Remove from compare'
                        : 'Add to compare',
                    onPressed: (isSelected || canSelectMore)
                        ? () => ref.read(compareProvider.notifier)
                            .toggle(device.id)
                        : null,
                    icon: Icon(
                      isSelected
                          ? Icons.compare_arrows
                          : Icons.compare_arrows_outlined,
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _subtitle {
    final year = device.year;
    return year == null
        ? device.category.label
        : '${device.category.label} • $year';
  }
}
