import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/device.dart';
import '../providers/compare_provider.dart';
import 'category_icon.dart';

/// Catalogue list item: a category-tinted label box, the device's key facts,
/// and a watchlist (compare) toggle.
///
/// A [ConsumerWidget] so it can reflect and mutate the watchlist selection
/// without the parent list rebuilding. Tapping the card opens the detail
/// screen, passing the already-loaded [Device] as router `extra`.
class DeviceCard extends ConsumerWidget {
  const DeviceCard({super.key, required this.device});

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final palette = colorsForCategory(device.category);
    final selectedIds = ref.watch(compareProvider);
    final isSelected = selectedIds.contains(device.id);
    final isFull = ref.watch(compareProvider.notifier).isFull;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.device(device.id), extra: device),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category colour block, e.g. "LAPTOP".
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  device.category.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${Formatters.price(device.price)} • Deposit '
                      '${Formatters.money(device.estimatedDeposit)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Watchlist (compare) toggle. Disabled once the 2-item cap is hit.
              IconButton(
                tooltip: isSelected
                    ? 'Remove from watchlist'
                    : 'Add to watchlist',
                visualDensity: VisualDensity.compact,
                onPressed: (isSelected || !isFull)
                    ? () => ref.read(compareProvider.notifier).toggle(device.id)
                    : null,
                icon: Icon(
                  isSelected ? Icons.bookmark : Icons.bookmark_border,
                  color: isSelected ? theme.colorScheme.primary : null,
                ),
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
        ? '${device.category.label} • Unknown year'
        : '${device.category.label} • $year';
  }
}
