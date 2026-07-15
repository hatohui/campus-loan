import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device.dart';
import 'catalogue_provider.dart';
import 'search_provider.dart';
import 'sort_provider.dart';

/// Derives the visible device list from the catalogue, search query and sort.
///
/// This is a pure derivation: it never mutates the source list from
/// [catalogueProvider]. Search is a case-insensitive name filter over the
/// already-loaded devices (so typing never re-hits the network). Sorting always
/// uses [Device.apiIndex] as a stable tiebreaker, which is how the original API
/// order is preserved, and devices with an unknown price sort by their derived
/// deposit ($20 tier) so missing prices are handled consistently (CR#4).
final filteredDevicesProvider = Provider<List<Device>>((ref) {
  final devices =
      ref.watch(catalogueProvider).valueOrNull?.devices ?? const <Device>[];
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final sort = ref.watch(sortProvider);

  final result = query.isEmpty
      ? [...devices]
      : devices
          .where((d) => d.name.toLowerCase().contains(query))
          .toList();

  switch (sort) {
    case SortOption.apiOrder:
      result.sort((a, b) => a.apiIndex.compareTo(b.apiIndex));
    case SortOption.depositLowHigh:
      result.sort((a, b) {
        final byDeposit = a.estimatedDeposit.compareTo(b.estimatedDeposit);
        return byDeposit != 0 ? byDeposit : a.apiIndex.compareTo(b.apiIndex);
      });
    case SortOption.nameAZ:
      result.sort((a, b) {
        final byName =
            a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return byName != 0 ? byName : a.apiIndex.compareTo(b.apiIndex);
      });
  }
  return result;
});
