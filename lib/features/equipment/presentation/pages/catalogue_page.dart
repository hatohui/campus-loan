import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/widgets/app_bottom_nav.dart';
import '../../../../core/error/failures.dart';
import '../providers/catalogue_provider.dart';
import '../providers/compare_provider.dart';
import '../providers/filtered_devices_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/catalogue_search_bar.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/device_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/sort_menu.dart';
import '../widgets/watchlist_sheet.dart';

/// Screen A — the device catalogue.
///
/// Handles all four load states (loading / error / empty / data) via the
/// catalogue's `AsyncValue`, shows the offline banner when serving cache, and
/// supports pull-to-refresh. Category chips + search + sort compose into the
/// derived [filteredDevicesProvider].
class CataloguePage extends ConsumerWidget {
  const CataloguePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogue = ref.watch(catalogueProvider);
    final isFromCache = catalogue.valueOrNull?.isFromCache ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Equipment'),
        actions: const [SortMenu()],
      ),
      bottomNavigationBar: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [_ViewWatchlistBar(), AppBottomNav()],
      ),
      body: Column(
        children: [
          const CatalogueSearchBar(),
          const CategoryFilterChips(),
          if (isFromCache) const OfflineBanner(),
          const SizedBox(height: 4),
          Expanded(
            child: catalogue.when(
              skipLoadingOnRefresh: true,
              skipLoadingOnReload: true,
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorView(
                message: error is Failure
                    ? error.message
                    : 'Something went wrong.',
                onRetry: () => ref.read(catalogueProvider.notifier).refresh(),
              ),
              data: (_) => _DeviceList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Persistent "VIEW WATCHLIST" bar above the bottom navigation.
class _ViewWatchlistBar extends ConsumerWidget {
  const _ViewWatchlistBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(compareProvider).length;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => showWatchlistSheet(context),
          child: Text(
            count == 0 ? 'VIEW WATCHLIST' : 'VIEW WATCHLIST ($count)',
          ),
        ),
      ),
    );
  }
}

/// The refreshable list of (filtered, sorted) devices, with an empty state.
class _DeviceList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(filteredDevicesProvider);
    final hasQuery = ref.watch(searchQueryProvider).isNotEmpty;

    return RefreshIndicator(
      onRefresh: () => ref.read(catalogueProvider.notifier).refresh(),
      child: devices.isEmpty
          ? _EmptyView(hasQuery: hasQuery)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: devices.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  DeviceCard(device: devices[index]),
            ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    // Wrapped in a scrollable so pull-to-refresh still works when empty.
    return ListView(
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
        Center(
          child: Text(
            hasQuery
                ? 'No devices match your search.'
                : 'No devices available.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder + scroll view keeps the content centred when there is room
    // and scrollable (no overflow) when the viewport is short.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
