import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/device.dart';
import '../providers/catalogue_provider.dart';
import '../providers/compare_provider.dart';
import 'category_icon.dart';

/// Opens the watchlist (comparison list, CR#2) as a modal bottom sheet.
void showWatchlistSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const _WatchlistSheet(),
  );
}

class _WatchlistSheet extends ConsumerWidget {
  const _WatchlistSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ids = ref.watch(compareProvider);
    final devices =
        ref.watch(catalogueProvider).valueOrNull?.devices ?? const <Device>[];
    final selected =
        devices.where((d) => ids.contains(d.id)).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Watchlist', style: theme.textTheme.titleLarge),
                ),
                if (selected.isNotEmpty)
                  TextButton(
                    onPressed: ref.read(compareProvider.notifier).clear,
                    child: const Text('Clear'),
                  ),
              ],
            ),
            Text(
              'Compare up to ${AppConstants.maxCompareItems} devices',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 12),
            if (selected.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Your watchlist is empty.\nTap the bookmark on a device to add it.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
            else
              for (final device in selected)
                _WatchlistTile(device: device),
          ],
        ),
      ),
    );
  }
}

class _WatchlistTile extends ConsumerWidget {
  const _WatchlistTile({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = colorsForCategory(device.category);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: palette.background,
        foregroundColor: palette.foreground,
        child: Icon(iconForCategory(device.category)),
      ),
      title: Text(device.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${Formatters.price(device.price)} • Deposit '
        '${Formatters.money(device.estimatedDeposit)}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Remove',
        onPressed: () => ref.read(compareProvider.notifier).toggle(device.id),
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.push(AppRoutes.device(device.id), extra: device);
      },
    );
  }
}
